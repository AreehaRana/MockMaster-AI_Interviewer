export 'gemini_feedback_service.dart';

import 'gemini_feedback_service.dart';
import 'ollama_feedback_service.dart';
import 'package:mockmaster/utils/network/connectivity_service.dart';

/// Single entry point FeedbackScreen should call. Picks the right
/// backend based on connectivity, and NEVER hangs -- every path has a
/// timeout, and any failure falls back to a strict local evaluation
/// instead of spinning forever.
///
///   Internet available -> Gemini (better quality grading)
///   No internet        -> Ollama (local model, works offline)
///   Both fail          -> strict heuristic (non-answers still score 0)
///
/// Scoring rules are enforced in gemini_feedback_service.dart
/// (AnswerGuard + InterviewEvaluation.fromModelJson), so NO path --
/// Gemini, Ollama, or heuristic -- can award marks for "I don't know",
/// a blank transcript, or filler-only speech.
///
/// The `export` above re-shares InterviewEvaluation/QuestionEvaluation
/// (and now AnswerGuard) so any file that imports THIS file (like
/// feedback_screen.dart) can use those types without also importing
/// gemini_feedback_service.dart directly.
class FeedbackService {
  static Future<InterviewEvaluation?> evaluateAnswers({
    required List<String> questions,
    required Map<int, String> answers,
  }) async {
    if (questions.isEmpty) return null;

    final online = await ConnectivityService.hasInternet();

    if (online) {
      final geminiResult = await GeminiFeedbackService.evaluateAnswers(
        questions: questions,
        answers: answers,
      );
      if (geminiResult != null) return geminiResult;
      // Gemini failed even though we're online (quota, bad key, etc.) --
      // still try Ollama before giving up completely.
    }

    final ollamaResult = await OllamaFeedbackService.evaluateAnswers(
      questions: questions,
      answers: answers,
    );
    if (ollamaResult != null) return ollamaResult;

    // Last resort: a deliberately conservative local estimate. It still
    // hard-zeroes refusals and blanks, and caps everything else at 60
    // because nothing actually verified correctness.
    return InterviewEvaluation.heuristic(
      questions: questions,
      answers: answers,
    );
  }
}