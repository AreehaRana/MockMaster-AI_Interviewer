import 'dart:convert';
import 'package:http/http.dart' as http;

/// Calls a locally-running Ollama model to generate interview questions.
/// No API key needed -- Ollama runs on your own machine at OLLAMA_HOST.
class OllamaQuestionService {
  // 'localhost' works when testing on desktop/emulator on the SAME machine
  // running Ollama. If testing on a REAL PHONE, replace with your PC's
  // LAN IP, e.g. 'http://192.168.1.5:11434' (find it via `ipconfig`).
  static const String _baseUrl = 'http://localhost:11434';
  static const String _model = 'llama3.1:8b';

  static Future<List<String>> generateQuestions({
    required String role,
    required List<String> technologies,
    required bool isTechnical,
    String difficulty = 'Medium',
    int count = 8,
  }) async {
    final prompt =
        '''
You are an expert interviewer. Generate $count realistic, distinct interview
questions for a "$role" position at $difficulty difficulty.
${isTechnical ? 'Focus on technical depth involving: ${technologies.join(", ")}.' : 'Focus on practical, role-specific scenarios involving: ${technologies.join(", ")}.'}
Return ONLY a JSON array of strings -- no markdown, no commentary, no extra text before or after.
Example: ["question 1", "question 2"]
''';

    final response = await http.post(
      Uri.parse('$_baseUrl/api/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': _model,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'stream': false,
        // Nudges Ollama to constrain output to valid JSON where supported
        'format': 'json',
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Ollama request failed (${response.statusCode}): ${response.body}',
      );
    }

    final body = jsonDecode(response.body);
    final text = body['message']?['content'] as String?;

    if (text == null || text.isEmpty) {
      throw Exception('Empty response from Ollama');
    }

    final decoded = _extractJsonArray(text);
    if (decoded is List && decoded.isNotEmpty) {
      return decoded.map((e) => e.toString()).toList();
    }
    throw Exception('Unexpected response format from Ollama: $text');
  }

  /// Local models sometimes wrap JSON in markdown fences or add stray text.
  /// This pulls out the first [...] block and parses it, instead of
  /// assuming the response is pure JSON like Gemini's responseMimeType did.
  static dynamic _extractJsonArray(String text) {
    final match = RegExp(r'\[[\s\S]*\]').firstMatch(text);
    if (match == null) {
      throw Exception('No JSON array found in model output: $text');
    }
    return jsonDecode(match.group(0)!);
  }
}