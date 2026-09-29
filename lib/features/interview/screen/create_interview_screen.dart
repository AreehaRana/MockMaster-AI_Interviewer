import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockmaster/common/widgets/m_gradient_background.dart';
import 'package:mockmaster/common/widgets/m_glass_card.dart';
import 'package:mockmaster/common/widgets/m_glass_button.dart';
import 'package:mockmaster/features/interview/screen/interview_screen.dart';
import 'package:mockmaster/features/interview/services/gemini_question_service.dart';
import 'package:mockmaster/features/interview/services/stripe_payment_service.dart';
import 'package:mockmaster/data/services/payment_service.dart';
import 'package:mockmaster/utils/network/connectivity_service.dart';
import 'package:mockmaster/utils/helpers/pricing_calculator.dart';
import 'package:mockmaster/utils/constants/sizes.dart';
import 'package:mockmaster/utils/constants/text_strings.dart';

class CreateInterviewScreen extends StatefulWidget {
  const CreateInterviewScreen({super.key});

  @override
  State<CreateInterviewScreen> createState() => _CreateInterviewScreenState();
}

class _CreateInterviewScreenState extends State<CreateInterviewScreen> {
  final _roleController = TextEditingController();

  String _selectedDuration = MTexts.durationOptions.first;
  String _selectedQuestionCount = MTexts.questionCountOptions.first;
  String _selectedDifficulty = MTexts.difficultyEasy;

  bool _isGenerating = false;

  final List<String> _difficultyOptions = const [
    MTexts.difficultyEasy,
    MTexts.difficultyMedium,
    MTexts.difficultyHard,
  ];

  @override
  void dispose() {
    _roleController.dispose();
    super.dispose();
  }

  int get _parsedQuestionCount {
    final digits = RegExp(r'\d+').firstMatch(_selectedQuestionCount);
    return digits != null
        ? int.parse(digits.group(0)!)
        : MTexts.genericInterviewQuestions.length;
  }

  Future<void> _startInterview() async {
    // Custom Interview needs Gemini, which needs the internet -- check
    // BEFORE charging the user for something that can't run.
    final online = await ConnectivityService.hasInternet();
    if (!online) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Custom Interview needs an internet connection. Please connect and try again.',
          ),
        ),
      );
      return;
    }

    final typedRole = _roleController.text.trim();
    final title = typedRole.isEmpty ? MTexts.startInterview : typedRole;

    setState(() => _isGenerating = true);

    // Custom interviews are paid -- charge before generating anything.
    // quantity is always 1 here (one interview being created right now).
    final amountDue = MPricingCalculator.calculateTotalPrice(1);

    try {
      final paid = await StripePaymentService.payForCustomInterview(amountDue);
      if (!mounted) return;

      if (!paid) {
        // User closed the payment sheet without paying -- not an error,
        // just stop here and let them try again.
        setState(() => _isGenerating = false);
        return;
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
      );
      return;
    }

    // Payment succeeded -- record it so the admin panel can see who paid.
    // Fire-and-forget: a logging failure shouldn't block the interview.
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      PaymentService.recordPayment(
        uid: user.uid,
        userEmail: user.email ?? 'Unknown',
        amount: amountDue,
        interviewTitle: title,
      ).catchError((e) => debugPrint('Failed to record payment: $e'));
    }

    // Static bank stays as the fallback.
    final bank = MTexts.genericInterviewQuestions;
    List<String> questions = List<String>.generate(
      _parsedQuestionCount,
      (i) => bank[i % bank.length],
    );

    try {
      final generated = await GeminiQuestionService.generateQuestions(
        role: title,
        technologies: const [], // custom flow has no fixed tech list
        isTechnical: true,
        difficulty: _selectedDifficulty,
        count: _parsedQuestionCount,
      );
      if (generated.isNotEmpty) questions = generated;
    } catch (e) {
      debugPrint('Gemini generation failed, using static questions: $e');
    }

    if (!mounted) return;
    setState(() => _isGenerating = false);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InterviewScreen(title: title, questions: questions),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Transparent scaffold + app bar so the ombre gradient shows through everywhere.
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(MTexts.createInterviewTitle),
      ),
      body: MGradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: MGlassCard(
                maxWidth: 480,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      MTexts.desiredInterviewLabel,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: MSizes.spaceBtwItems / 2),
                    TextFormField(
                      controller: _roleController,
                      decoration: const InputDecoration(
                        hintText: MTexts.desiredInterviewHint,
                      ),
                    ),
                    const SizedBox(height: MSizes.spaceBtwSections),

                    Text(
                      MTexts.interviewDurationLabel,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: MSizes.spaceBtwItems / 2),
                    DropdownButtonFormField<String>(
                      value: _selectedDuration,
                      items: MTexts.durationOptions
                          .map((option) => DropdownMenuItem(
                                value: option,
                                child: Text(option),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedDuration = value);
                        }
                      },
                    ),
                    const SizedBox(height: MSizes.spaceBtwSections),

                    Text(
                      MTexts.numberOfQuestions,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: MSizes.spaceBtwItems / 2),
                    DropdownButtonFormField<String>(
                      value: _selectedQuestionCount,
                      items: MTexts.questionCountOptions
                          .map((option) => DropdownMenuItem(
                                value: option,
                                child: Text(option),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedQuestionCount = value);
                        }
                      },
                    ),
                    const SizedBox(height: MSizes.spaceBtwSections),

                    Text(
                      MTexts.selectDifficulty,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: MSizes.spaceBtwItems / 2),
                    DropdownButtonFormField<String>(
                      value: _selectedDifficulty,
                      items: _difficultyOptions
                          .map((option) => DropdownMenuItem(
                                value: option,
                                child: Text(option),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedDifficulty = value);
                        }
                      },
                    ),
                    const SizedBox(height: MSizes.spaceBtwSections),

                    _isGenerating
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Center(
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          )
                        : MGlassButton.filled(
                            label:
                                'Pay ${MPricingCalculator.getFormattedPrice(1)} & ${MTexts.startAnInterview}',
                            icon: Icons.play_arrow_rounded,
                            onPressed: _startInterview,
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}