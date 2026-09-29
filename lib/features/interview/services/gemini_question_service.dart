import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Asks Gemini to write interview questions tailored to exactly what the
/// user typed on CreateInterviewScreen (role/topic, difficulty, count) --
/// NOT the static generic question bank. That bank is only a fallback for
/// when this call fails (missing/invalid key, no internet, quota, etc).
class GeminiQuestionService {
  static Future<
    List<
      String
    >
  >
  generateQuestions({
    required String
    role,
    required List<
      String
    >
    technologies,
    required bool
    isTechnical,
    required String
    difficulty,
    required int
    count,
  }) async {
    // IMPORTANT: reads from the .env file via flutter_dotenv (loaded once
    // in main.dart), NOT String.fromEnvironment/--dart-define. Those are
    // two completely different mechanisms -- using the wrong one means
    // this silently always fails and falls back to generic questions,
    // with no visible error.
    final apiKey =
        dotenv.env['GEMINI_API_KEY'];
    if (apiKey ==
            null ||
        apiKey.isEmpty) {
      debugPrint(
        'GEMINI_API_KEY missing from .env -- using generic fallback questions.',
      );
      return [];
    }

    // gemini-1.5-flash is fully shut down as of 2026 -- every call to it
    // returns a 404, which was silently caught below and made this ALWAYS
    // fall back to generic questions. gemini-3.6-flash is current and is
    // already what GeminiFeedbackService uses, so both services now stay
    // on the same model.
    final model = GenerativeModel(
      model: 'gemini-3.6-flash',
      apiKey: apiKey,
    );

    final techLine =
        technologies.isNotEmpty
        ? 'Focus specifically on these technologies: ${technologies.join(", ")}.'
        : '';

    // The user's exact typed role/topic is the core of this prompt --
    // this is what makes the questions relevant to THEIR interview
    // instead of generic ones.
    final prompt =
        '''
You are an expert interviewer. The candidate wants to practice for this
exact role/topic they typed themselves: "$role"
$techLine
Difficulty level: $difficulty.
${isTechnical ? 'Write technical, skill-testing questions specific to "$role".' : 'Write behavioral / soft-skill questions relevant to "$role".'}

Generate exactly $count interview questions, each directly relevant to
"$role" -- do not write generic questions that could apply to any job.

Return ONLY a raw JSON array of strings -- no markdown fences, no extra
text, no numbering. Example: ["Question 1?", "Question 2?"]
''';

    try {
      final response = await model.generateContent([
        Content.text(
          prompt,
        ),
      ]);
      final rawText =
          response.text?.trim() ??
          '';
      final cleaned = rawText
          .replaceAll(
            RegExp(
              r'```json|```',
            ),
            '',
          )
          .trim();

      final decoded = jsonDecode(
        cleaned,
      );
      if (decoded
          is List) {
        final questions = decoded
            .map(
              (
                e,
              ) => e.toString(),
            )
            .toList();
        if (questions.isNotEmpty) return questions;
      }
      debugPrint(
        'Gemini returned an unexpected shape, using fallback: $rawText',
      );
      return [];
    } catch (
      e
    ) {
      debugPrint(
        'Gemini question generation failed, using fallback: $e',
      );
      return [];
    }
  }
}
