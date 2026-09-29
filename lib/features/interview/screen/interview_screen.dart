import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:mockmaster/features/interview/screen/feedback_screen.dart';
import 'package:mockmaster/utils/constants/image_strings.dart';
import 'package:mockmaster/utils/constants/sizes.dart';
import 'package:mockmaster/utils/constants/text_strings.dart';
import 'package:mockmaster/utils/helpers/helper_function.dart';

class InterviewScreen extends StatefulWidget {
  final String title;
  final List<String> questions;

  const InterviewScreen({
    super.key,
    required this.title,
    required this.questions,
  });

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  static const int _answerSeconds = 20;

  int _currentIndex = 0;

  // -- Voice pipeline --------------------------------------------------
  late final FlutterTts _tts;
  late final stt.SpeechToText _speech;
  bool _speechAvailable = false;
  bool _isSpeaking = false;
  bool _isListening = false;
  int _secondsLeft = _answerSeconds;
  Timer? _timer;

  /// question index -> transcribed answer text (compared later on
  /// FeedbackScreen)
  final Map<int, String> _answers = {};

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _speech = stt.SpeechToText();
    _setupVoice();
  }

  Future<void> _setupVoice() async {
    await _tts.setLanguage("en-US");

    // ---------------------------------------------------------------
    // VOICE SELECTION -- this is the actual fix for "female/robotic
    // voice on real phone". Without this, the OS just picks whatever
    // its own default TTS voice happens to be, which varies device to
    // device (often female on stock Android). We ask the engine for
    // every installed voice, then try to lock onto a male en-US one.
    // ---------------------------------------------------------------
    try {
      final dynamic rawVoices = await _tts.getVoices;
      if (rawVoices is List) {
        // Print once so you can see the exact names available on THIS
        // phone -- open `flutter logs` or Logcat and search "TTS voices".
        debugPrint('TTS voices available on this device: $rawVoices');

        Map<String, dynamic>? chosen;

        for (final v in rawVoices) {
          if (v is Map) {
            final name = (v['name'] ?? '').toString().toLowerCase();
            final locale = (v['locale'] ?? '').toString().toLowerCase();
            final isEnglish = locale.startsWith('en-us') || locale.startsWith('en_us');
            final looksMale = name.contains('male') && !name.contains('female');

            if (isEnglish && looksMale) {
              chosen = Map<String, dynamic>.from(v);
              break; // first good match wins
            }
          }
        }

        // Fallback: some engines label male voices without the word
        // "male" at all (e.g. Android's "en-us-x-iom-local",
        // "en-us-x-iob-local" are commonly male on Google TTS). Try a
        // couple of known Android male voice ids if the pass above
        // found nothing.
        if (chosen == null) {
          const knownMaleIds = [
            'en-us-x-iom-local',
            'en-us-x-iob-local',
            'en-us-x-tpd-local',
          ];
          for (final v in rawVoices) {
            if (v is Map) {
              final name = (v['name'] ?? '').toString();
              if (knownMaleIds.contains(name)) {
                chosen = Map<String, dynamic>.from(v);
                break;
              }
            }
          }
        }

        if (chosen != null) {
          debugPrint('TTS voice chosen: $chosen');
          await _tts.setVoice({
            'name': chosen['name'].toString(),
            'locale': chosen['locale'].toString(),
          });
        } else {
          debugPrint('No explicit male voice found -- using device default.');
        }
      }
    } catch (e) {
      // Never let voice selection crash the interview -- worst case we
      // just fall back to whatever voice the device already had.
      debugPrint('TTS voice selection failed, using device default: $e');
    }

    // ---------------------------------------------------------------
    // SPEED + PITCH
    // 0.62 measured "too fast" on real devices even though it read as
    // brisk-but-normal on the emulator -- different phones/engines map
    // the 0.0-1.0 rate scale differently. 0.45 is a safer, slower,
    // clearly-paced default for an interview read-aloud. Tweak between
    // ~0.40-0.50 if it still feels off on your target devices.
    // Pitch is nudged slightly down (0.9) since a lower pitch reads as
    // more naturally male/deeper on most TTS engines.
    // ---------------------------------------------------------------
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(0.9);

    // Once the question finishes being read aloud, start listening.
    _tts.setCompletionHandler(() {
      if (mounted) _startListening();
    });

    _speechAvailable = await _speech.initialize(
      onError: (e) => debugPrint('Speech error: $e'),
      onStatus: (status) => debugPrint('Speech status: $status'),
    );

    if (mounted) _askCurrentQuestion();
  }

  Future<void> _askCurrentQuestion() async {
    await _resetListeningState(); // fully clear previous question's voice state
    await _tts.stop();
    setState(() {
      _isSpeaking = true;
      _secondsLeft = _answerSeconds;
    });
    await _tts.speak(widget.questions[_currentIndex]);
  }

  /// Fully discards any in-progress or leftover speech session so the next
  /// question starts with a clean slate -- cancel() (not stop()) clears the
  /// recognizer's internal buffer, which stop() alone does not guarantee.
  Future<void> _resetListeningState() async {
    _timer?.cancel();
    if (_speech.isListening) {
      await _speech.cancel();
    }
    if (mounted) {
      setState(() => _isListening = false);
    }
  }

  Future<void> _startListening() async {
    if (!mounted) return;
    await _resetListeningState(); // safety: ensure clean state before listening
    setState(() => _isSpeaking = false);

    if (!_speechAvailable) return;

    setState(() {
      _isListening = true;
      _secondsLeft = _answerSeconds;
    });

    await _speech.listen(
      onResult: (result) {
        // Overwrites any prior partial result for THIS question only --
        // _answers is keyed by _currentIndex, so it never touches other
        // questions' stored answers.
        setState(() => _answers[_currentIndex] = result.recognizedWords);
      },
      listenFor: const Duration(seconds: _answerSeconds),
      pauseFor: const Duration(seconds: _answerSeconds),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        t.cancel();
        _stopListening();
      }
    });
  }

  void _stopListening() {
    _timer?.cancel();
    if (_speech.isListening) _speech.stop(); // finalize normally when time runs out
    if (mounted) setState(() => _isListening = false);
  }

  // -- Navigation --------------------------------------------------------
  void _moveTo(int newIndex) {
    setState(() => _currentIndex = newIndex);
    _askCurrentQuestion();
  }

  void _goToPrevious() {
    if (_currentIndex > 0) _moveTo(_currentIndex - 1);
  }

  void _goToNext() {
    if (_currentIndex < widget.questions.length - 1) {
      _moveTo(_currentIndex + 1);
    }
  }

  void _endInterview() {
    _stopListening();
    _tts.stop();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => FeedbackScreen(
          interviewTitle: widget.title,
          questions: widget.questions,
          answers: _answers, // {questionIndex: transcribedAnswer}
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = MHelperFunctions.isDarkMode(context);
    final scheme = Theme.of(context).colorScheme;
    final totalQuestions = widget.questions.length;
    final currentQuestion = widget.questions[_currentIndex];
    final currentAnswer = _answers[_currentIndex] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(MSizes.defaultSpace),
          child: Column(
            children: [
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    Expanded(
                      child: _ParticipantPanel(
                        isUser: true,
                        dark: dark,
                        scheme: scheme,
                        label: 'You',
                        isActive: _isListening,
                      ),
                    ),
                    const SizedBox(width: MSizes.md),
                    Expanded(
                      child: _ParticipantPanel(
                        isUser: false,
                        dark: dark,
                        scheme: scheme,
                        label: 'AI Interviewer',
                        isActive: _isSpeaking,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: MSizes.spaceBtwSections),

              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(MSizes.md),
                  decoration: BoxDecoration(
                    color: dark
                        ? scheme.surfaceContainerHigh
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(MSizes.cardRadiusLg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${MTexts.questionLabel} ${_currentIndex + 1} / $totalQuestions',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: MSizes.sm),
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            // Long, AI-generated questions can exceed the
                            // available space on small phones -- scroll
                            // instead of overflowing/clipping.
                            child: Text(
                              currentQuestion,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                        ),
                      ),

                      // -- Voice status row -----------------------------
                      Row(
                        children: [
                          Icon(
                            _isSpeaking
                                ? Icons.volume_up_rounded
                                : _isListening
                                    ? Icons.mic_rounded
                                    : Icons.mic_none_rounded,
                            color: _isListening ? scheme.error : scheme.primary,
                          ),
                          const SizedBox(width: MSizes.sm),
                          Expanded(
                            child: Text(
                              _isSpeaking
                                  ? 'Reading question...'
                                  : _isListening
                                      ? 'Listening... ${_secondsLeft}s left'
                                      : 'Waiting',
                              style: Theme.of(context).textTheme.labelMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (currentAnswer.isNotEmpty) ...[
                        const SizedBox(height: MSizes.sm),
                        Text(
                          '"$currentAnswer"',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: MSizes.spaceBtwSections),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _currentIndex > 0 ? _goToPrevious : null,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: const Text(MTexts.previousQuestion),
                      ),
                    ),
                  ),
                  const SizedBox(width: MSizes.sm),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _currentIndex < totalQuestions - 1 ? _goToNext : null,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: const Text(MTexts.skipQuestion),
                      ),
                    ),
                  ),
                  const SizedBox(width: MSizes.sm),
                  Expanded(
                    // Was ElevatedButton (solid fill) -- switched to
                    // OutlinedButton so it visually matches
                    // Previous/Skip's glass-like transparent look
                    // instead of standing out as a solid block.
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: scheme.primary),
                        foregroundColor: scheme.primary,
                      ),
                      onPressed: _currentIndex < totalQuestions - 1 ? _goToNext : null,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: const Text(MTexts.nextQuestion),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: MSizes.spaceBtwItems),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).colorScheme.error),
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: _endInterview,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: const Text(MTexts.endInterview),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParticipantPanel extends StatelessWidget {
  final bool isUser;
  final bool dark;
  final ColorScheme scheme;
  final String label;
  final bool isActive;

  const _ParticipantPanel({
    required this.isUser,
    required this.dark,
    required this.scheme,
    required this.label,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: dark ? scheme.surfaceContainerHigh : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(MSizes.cardRadiusLg),
        border: isActive ? Border.all(color: scheme.primary, width: 2) : null,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Avatar/icon size is derived from whichever dimension of this
          // specific panel is tighter (width or height), instead of a
          // fixed size -- so it never overflows on narrow phones or very
          // short screens, and scales up nicely on tablets/desktop.
          final avatarSize = (constraints.maxWidth < constraints.maxHeight
                  ? constraints.maxWidth
                  : constraints.maxHeight) *
              0.35;
          final clampedAvatarSize = avatarSize.clamp(32.0, MSizes.iconLg * 2);

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isUser)
                CircleAvatar(
                  radius: clampedAvatarSize / 2,
                  backgroundColor: scheme.primary.withValues(alpha: 0.15),
                  child: Icon(
                    Icons.person_rounded,
                    size: clampedAvatarSize * 0.6,
                    color: scheme.primary,
                  ),
                )
              else
                Image.asset(
                  MImages.aiAvatar,
                  height: clampedAvatarSize,
                ),
              const SizedBox(height: MSizes.sm),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}