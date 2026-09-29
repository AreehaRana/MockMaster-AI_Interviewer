import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockmaster/common/widgets/m_gradient_background.dart';
import 'package:mockmaster/common/widgets/m_glass_panel.dart';
import 'package:mockmaster/common/widgets/m_glass_button.dart';
import 'package:mockmaster/features/home/screens/home_screen.dart';
import 'package:mockmaster/features/interview/services/feedback_pdf_service.dart';
import 'package:mockmaster/features/interview/services/interview_session_services.dart';
import 'package:mockmaster/utils/constants/sizes.dart';
import 'package:mockmaster/utils/constants/text_strings.dart';
import 'package:mockmaster/utils/helpers/helper_function.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mockmaster/features/interview/services/feedback_service.dart';

/// Shown after the user taps "End Interview".
///
/// Answers are sent to [FeedbackService], which picks Gemini (when
/// online) or the local Ollama model (when offline) automatically -- if
/// both fail, a basic completion/substance heuristic is used instead
/// (see [_buildFallbackEvaluation]), so the screen always has something
/// to show and never gets stuck loading. "Save as PDF" exports the
/// score, strengths, improvements and full transcript via
/// [FeedbackPdfService].
class FeedbackScreen extends StatefulWidget {
  final String interviewTitle;
  final List<String> questions;

  /// questionIndex -> transcribed answer (from speech-to-text). A missing
  /// or empty entry means the question was skipped / not answered.
  final Map<int, String> answers;

  const FeedbackScreen({
    super.key,
    required this.interviewTitle,
    required this.questions,
    required this.answers,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  InterviewEvaluation? _evaluation;
  bool _loading = true;
  bool _usedFallback = false;
  bool _savingPdf = false;

  @override
  void initState() {
    super.initState();
    _loadEvaluation();
  }

  Future<void> _loadEvaluation() async {
    InterviewEvaluation? result;
    try {
      result = await FeedbackService.evaluateAnswers(
        questions: widget.questions,
        answers: widget.answers,
      ).timeout(const Duration(seconds: 30));
    } catch (e) {
      result = null;
    }

    if (!mounted) return;

    if (result != null) {
      setState(() {
        _evaluation = result;
        _loading = false;
      });
      _recordSession(result);
    } else {
      // Both Gemini and Ollama failed/unreachable/timed out -- fall back
      // to the honest heuristic (completion rate + answer substance) so
      // the screen never gets stuck, even if the user skipped everything.
      final fallback = _buildFallbackEvaluation();
      setState(() {
        _evaluation = fallback;
        _usedFallback = true;
        _loading = false;
      });
      _recordSession(fallback);
    }
  }

  /// Saves this completed interview to Firestore so it counts toward the
  /// drawer's "Interviews Completed" number and shows up in
  /// InterviewHistoryScreen's list of which interviews were taken.
  /// Fire-and-forget: a save failure shouldn't block the user from seeing
  /// their results on this screen.
  void _recordSession(InterviewEvaluation eval) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return; // guest session -- nothing to attach history to

    final answeredCount =
        widget.answers.values.where((a) => a.trim().isNotEmpty).length;

    InterviewSessionService.instance
        .recordSession(
          uid: uid,
          interviewTitle: widget.interviewTitle,
          overallScore: eval.overallScore,
          totalQuestions: widget.questions.length,
          answeredQuestions: answeredCount,
        )
        .catchError((e) => debugPrint('Failed to record interview session: $e'));
  }

  InterviewEvaluation _buildFallbackEvaluation() {
    final total = widget.questions.length;
    final answered =
        widget.answers.values.where((a) => a.trim().isNotEmpty).length;
    final skipped = total - answered;
    final avgWords = answered == 0
        ? 0.0
        : widget.answers.values
                .where((a) => a.trim().isNotEmpty)
                .fold<int>(
                  0,
                  (sum, a) => sum + a.trim().split(RegExp(r'\s+')).length,
                ) /
            answered;

    final score = total == 0
        ? 0
        : (((answered / total) * 60) +
                ((avgWords / 40).clamp(0, 1) * 40))
            .round()
            .clamp(0, 100);

    return InterviewEvaluation(
      overallScore: score,
      strengths: answered > 0
          ? ['You answered $answered of $total questions']
          : ['You completed the session'],
      improvements: skipped > 0
          ? ['$skipped question${skipped == 1 ? '' : 's'} were skipped or unanswered']
          : ['Keep practicing to build confidence under time pressure'],
      perQuestion: List.generate(total, (i) {
        final a = widget.answers[i]?.trim() ?? '';
        return QuestionEvaluation(
          index: i,
          wasAnswered: a.isNotEmpty,
          score: a.isEmpty ? 0 : 50,
          feedback: a.isEmpty ? 'No answer recorded' : 'Not verified (AI grading unavailable)',
        );
      }),
    );
  }

  Color _scoreColor(int score, ColorScheme scheme) {
    if (score >= 75) return Colors.green;
    if (score >= 45) return Colors.orange;
    return scheme.error;
  }

  String _scoreLabel(int score) {
    if (score >= 75) return 'Strong session';
    if (score >= 45) return 'Decent start';
    return 'Needs more practice';
  }

  List<_Resource> _buildResources() {
    final text =
        ('${widget.interviewTitle} ${widget.questions.join(' ')}').toLowerCase();
    final resources = <_Resource>[];

    if (text.contains('javascript') || text.contains('js')) {
      resources.add(_Resource('JavaScript basics', 'https://www.w3schools.com/js/'));
    }
    if (text.contains('html') || text.contains('css')) {
      resources.add(_Resource('HTML & CSS reference', 'https://www.w3schools.com/html/'));
    }
    if (text.contains('python')) {
      resources.add(_Resource('Python tutorial', 'https://www.w3schools.com/python/'));
    }
    if (text.contains('sql') || text.contains('database')) {
      resources.add(_Resource('SQL reference', 'https://www.w3schools.com/sql/'));
    }
    if (text.contains('react') || text.contains('flutter') || text.contains('frontend')) {
      resources.add(_Resource('Frontend practice projects', 'https://www.freecodecamp.org/'));
    }
    if (text.contains('algorithm') || text.contains('data structure')) {
      resources.add(_Resource('Coding practice problems', 'https://leetcode.com/'));
    }
    if (text.contains('behavioral') || text.contains('hr')) {
      resources.add(_Resource(
        'STAR method for behavioral answers',
        'https://www.themuse.com/advice/star-interview-method',
      ));
    }
    resources.add(_Resource('General interview prep guide', 'https://www.indeed.com/career-advice/interviewing'));
    resources.add(_Resource('MDN Web Docs (for technical depth)', 'https://developer.mozilla.org/'));

    final seen = <String>{};
    return resources.where((r) => seen.add(r.url)).take(5).toList();
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) MHelperFunctions.showSnackBar('Could not open link');
    }
  }

  Future<void> _savePdf() async {
    if (_evaluation == null || _savingPdf) return;
    setState(() => _savingPdf = true);

    try {
      final result = await FeedbackPdfService.generateAndSave(
        interviewTitle: widget.interviewTitle,
        questions: widget.questions,
        answers: widget.answers,
        evaluation: _evaluation!,
      );
      if (mounted) {
        MHelperFunctions.showSnackBar(kIsWeb ? 'PDF downloaded' : 'Saved to $result');
      }
    } catch (e) {
      if (mounted) MHelperFunctions.showSnackBar('Could not save PDF: $e');
    } finally {
      if (mounted) setState(() => _savingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Transparent scaffold + app bar so the ombre gradient shows through everywhere.
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(MTexts.feedbackScreenTitle),
        ),
        body: MGradientBackground(
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Verifying your answers...'),
              ],
            ),
          ),
        ),
      );
    }

    final eval = _evaluation!;
    final scoreColor = _scoreColor(eval.overallScore, scheme);
    final answeredCount =
        widget.answers.values.where((a) => a.trim().isNotEmpty).length;
    final resources = _buildResources();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(MTexts.feedbackScreenTitle),
      ),
      body: MGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(MSizes.defaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.interviewTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: MSizes.spaceBtwSections),

                /// -- Overall Score card ------------------------------------
                MGlassPanel(
                  padding: const EdgeInsets.symmetric(vertical: MSizes.lg),
                  animate: false,
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 130,
                            width: 130,
                            child: CircularProgressIndicator(
                              value: eval.overallScore / 100,
                              strokeWidth: 10,
                              backgroundColor: scoreColor.withValues(alpha: 0.15),
                              valueColor: AlwaysStoppedAnimation(scoreColor),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${eval.overallScore}%',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: scoreColor,
                                    ),
                              ),
                              Text(
                                MTexts.feedbackOverallScore,
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: MSizes.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: MSizes.md, vertical: 4),
                        decoration: BoxDecoration(
                          color: scoreColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _scoreLabel(eval.overallScore),
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: scoreColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      const SizedBox(height: MSizes.sm),
                      Text(
                        '$answeredCount / ${widget.questions.length} questions answered',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (_usedFallback) ...[
                        const SizedBox(height: 2),
                        Text(
                          'AI grading unavailable — showing a basic completion-based score',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: MSizes.spaceBtwSections),

                /// -- Strengths --------------------------------------------------
                Text(MTexts.feedbackStrengths, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: MSizes.spaceBtwItems / 2),
                ...eval.strengths.map(
                  (point) => _FeedbackBullet(icon: Icons.check_circle_rounded, color: Colors.green, text: point),
                ),
                const SizedBox(height: MSizes.spaceBtwSections),

                /// -- Areas to Improve --------------------------------------------
                Text(MTexts.feedbackImprovements, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: MSizes.spaceBtwItems / 2),
                ...eval.improvements.map(
                  (point) => _FeedbackBullet(icon: Icons.error_outline_rounded, color: scheme.error, text: point),
                ),
                const SizedBox(height: MSizes.spaceBtwSections),

                /// -- Recommended Resources ----------------------------------
                Text('Recommended Resources', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: MSizes.spaceBtwItems / 2),
                ...resources.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: MSizes.sm),
                    child: MGlassPanel(
                      padding: EdgeInsets.zero,
                      animate: false,
                      child: ListTile(
                        leading: Icon(Icons.link_rounded, color: scheme.primary),
                        title: Text(r.title),
                        subtitle: Text(r.url, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                        trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                        onTap: () => _openLink(r.url),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: MSizes.spaceBtwSections),

                /// -- Question-by-Question ------------------------------------
                Text('Question-by-Question', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: MSizes.spaceBtwItems / 2),
                ...List.generate(widget.questions.length, (i) {
                  final answer = widget.answers[i]?.trim() ?? '';
                  final qEval = eval.perQuestion.length > i ? eval.perQuestion[i] : null;
                  final wasAnswered = qEval?.wasAnswered ?? answer.isNotEmpty;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: MSizes.sm),
                    child: MGlassPanel(
                      padding: const EdgeInsets.all(MSizes.md),
                      animate: false,
                      // Unanswered questions get an error-tinted border instead of the default glass border.
                      borderColor: wasAnswered ? null : scheme.error.withValues(alpha: 0.5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Q${i + 1}. ${widget.questions[i]}',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                              if (qEval != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _scoreColor(qEval.score, scheme).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${qEval.score}%',
                                    style: TextStyle(
                                      color: _scoreColor(qEval.score, scheme),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: MSizes.sm),
                          Text(
                            wasAnswered ? answer : 'No answer recorded (skipped)',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: wasAnswered ? null : scheme.error.withValues(alpha: 0.8),
                                  fontStyle: wasAnswered ? FontStyle.normal : FontStyle.italic,
                                ),
                          ),
                          if (qEval != null && qEval.feedback.isNotEmpty) ...[
                            const SizedBox(height: MSizes.sm),
                            Text(
                              qEval.feedback,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: MSizes.spaceBtwSections),

                /// -- Save as PDF ------------------------------------------------
                _savingPdf
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    : MGlassButton.outlined(
                        label: MTexts.savePdf,
                        icon: Icons.picture_as_pdf_rounded,
                        onPressed: _savePdf,
                      ),
                const SizedBox(height: MSizes.spaceBtwItems),

                /// -- Back to Dashboard --------------------------------------------
                MGlassButton.filled(
                  label: MTexts.backToDashboard,
                  icon: Icons.home_rounded,
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Resource {
  final String title;
  final String url;
  const _Resource(this.title, this.url);
}

/// Small reusable bullet row used for strengths/improvements above.
class _FeedbackBullet extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _FeedbackBullet({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: MSizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: MSizes.iconSm),
          const SizedBox(width: MSizes.sm),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}