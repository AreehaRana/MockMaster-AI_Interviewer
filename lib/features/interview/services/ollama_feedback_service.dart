import 'dart:convert';
import 'package:http/http.dart' as http;
import 'gemini_feedback_service.dart'
    show
        InterviewEvaluation,
        QuestionEvaluation,
        AnswerGuard,
        EvaluationPrompt;

class OllamaFeedbackService {
  static const String _baseUrl = 'http://localhost:11434';
  static const String _model = 'llama3.1:8b';

  static Future<InterviewEvaluation?> evaluateAnswers({
    required List<String> questions,
    required Map<int, String> answers,
  }) async {
    if (questions.isEmpty) return null;

    // Nothing was attempted -> guaranteed zero, no need to call the model.
    final attemptedAny = List.generate(questions.length, (i) => i).any(
      (i) => !AnswerGuard.isNonAnswer(answers[i]?.trim() ?? ''),
    );
    if (!attemptedAny) {
      return InterviewEvaluation.fromModelJson(
        {
          'overallScore': 0,
          'strengths': [],
          'improvements': [],
          'perQuestion': [],
        },
        questions: questions,
        answers: answers,
      );
    }

    // Exact same rubric as Gemini, so an offline run grades the same way.
    final prompt = EvaluationPrompt.build(
      EvaluationPrompt.buildPairs(questions: questions, answers: answers),
    );

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': _model,
              'messages': [
                {'role': 'user', 'content': prompt},
              ],
              'stream': false,
              'format': 'json',
              'options': {
                // Small local models are very generous by default; a low
                // temperature keeps the rubric from drifting upward.
                'temperature': 0.2,
                'num_predict': 2048,
              },
            }),
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body);
      final text = body['message']?['content'] as String?;
      if (text == null || text.isEmpty) return null;

      final decoded = _extractJsonObject(text);
      if (decoded is Map<String, dynamic>) {
        return InterviewEvaluation.fromModelJson(
          decoded,
          questions: questions,
          answers: answers,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static dynamic _extractJsonObject(String text) {
    final match = RegExp(r'\{[\s\S]*\}').firstMatch(text);
    if (match == null) return null;
    try {
      return jsonDecode(match.group(0)!);
    } catch (e) {
      return null;
    }
  }
}