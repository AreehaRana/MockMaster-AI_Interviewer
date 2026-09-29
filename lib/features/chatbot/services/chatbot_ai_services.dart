import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:mockmaster/utils/helpers/pricing_calculator.dart';
import 'package:mockmaster/utils/network/connectivity_service.dart';

// DEBUG VERSION -- same as chatbot_ai_service.dart but with debugPrint
// on every failure path so we can see the REAL error in the console
// instead of the generic "unavailable" message. Swap this in
// temporarily, check the console output, then we'll fix the real cause.
class ChatbotAiService {
  ChatbotAiService._();
  static final ChatbotAiService instance = ChatbotAiService._();

  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String _ollamaBaseUrl = 'http://localhost:11434';
  static const String _ollamaModel = 'llama3.1:8b';

  final List<Map<String, String>> _history = [];

  static String get _systemPrompt => '''
You are MockMaster AI Assistant, an AI Career and Interview Assistant
integrated into the MockMaster application.

Your primary responsibilities are:
1. Interview guidance.
2. Interview preparation.
3. MockMaster feature assistance.
4. Career Q&A.
5. Practice With Me.

MockMaster provides two interview options:
- Pre-generated Interviews: free demo interviews with 9 available interview cards.
- Custom Interview: a paid feature tailored to the user's role, technologies and difficulty. It requires an internet connection.
- The current Custom Interview price is ${MPricingCalculator.getFormattedPrice(1)}.

Hard rules:
- Never claim Custom Interview is free.
- Never invent a price.
- Never invent scores, weak topics or interview history.
- Keep responses professional, concise, encouraging and easy to read.
- Do not use Markdown formatting.
- Do not use #, ##, ###, **, *, _, ---, bullet symbols or Markdown links.
- Use simple numbered lists such as 1., 2., 3. when a list is needed.
- Use normal plain text only.
- Keep paragraphs short.
- Do not pretend to be a general-purpose assistant.
- Steer unrelated questions back to interview preparation, careers or MockMaster.
''';

  Future<String> sendMessage(String message, {String? userContext}) async {
    final composed = userContext == null || userContext.isEmpty
        ? message
        : '[User context -- factual, do not invent beyond this]\n'
            '$userContext\n\n'
            'User message: $message';

    _history.add({'role': 'user', 'content': composed});

    String? reply;
    final online = await ConnectivityService.hasInternet();
    debugPrint('[Chatbot DEBUG] online=$online, apiKeyEmpty=${_apiKey.isEmpty}');

    if (online && _apiKey.isNotEmpty) {
      try {
        reply = await _sendViaGemini().timeout(const Duration(seconds: 20));
        debugPrint('[Chatbot DEBUG] Gemini succeeded');
      } catch (e) {
        debugPrint('[Chatbot DEBUG] Gemini FAILED: $e');
        reply = null;
      }
    } else {
      debugPrint('[Chatbot DEBUG] Skipped Gemini (online=$online, apiKeyEmpty=${_apiKey.isEmpty})');
    }

    if (reply == null) {
      reply = await _sendViaOllamaSafely();
    }

    if (reply == null || reply.trim().isEmpty) {
      _history.removeLast();
      throw Exception(
        'MockMaster AI Assistant is unavailable right now. Please check '
        'your internet connection or try again in a moment.',
      );
    }

    final cleaned = _cleanResponse(reply);
    _history.add({'role': 'assistant', 'content': cleaned});
    return cleaned;
  }

  Future<String> _sendViaGemini() async {
    final model = GenerativeModel(
      model: 'gemini-3.6-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(_systemPrompt),
    );

    final contents = _history
        .map((m) => m['role'] == 'user'
            ? Content.text(m['content']!)
            : Content.model([TextPart(m['content']!)]))
        .toList();

    final response = await model.generateContent(contents);
    final text = response.text;
    if (text == null || text.trim().isEmpty) {
      throw Exception('Empty response from Gemini');
    }
    return text;
  }

  Future<String?> _sendViaOllamaSafely() async {
    try {
      final messages = [
        {'role': 'system', 'content': _systemPrompt},
        ..._history,
      ];

      final response = await http
          .post(
            Uri.parse('$_ollamaBaseUrl/api/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': _ollamaModel,
              'messages': messages,
              'stream': false,
            }),
          )
          .timeout(const Duration(seconds: 25));

      debugPrint('[Chatbot DEBUG] Ollama status=${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('[Chatbot DEBUG] Ollama body=${response.body}');
        return null;
      }

      final body = jsonDecode(response.body);
      final content = body['message']?['content'] as String?;
      debugPrint('[Chatbot DEBUG] Ollama succeeded, content length=${content?.length}');
      return content;
    } catch (e) {
      debugPrint('[Chatbot DEBUG] Ollama FAILED: $e');
      return null;
    }
  }

  String _cleanResponse(String text) {
    var cleaned = text;
    cleaned = cleaned.replaceAll(RegExp(r'#{1,6}\s*'), '');
    cleaned = cleaned.replaceAll('**', '');
    cleaned = cleaned.replaceAll('__', '');
    cleaned = cleaned.replaceAll(RegExp(r'(?<!\w)\*(?!\s)'), '');
    cleaned = cleaned.replaceAll(RegExp(r'^\s*[-*_]{3,}\s*$', multiLine: true), '');
    cleaned = cleaned.replaceAll(RegExp(r'^\s*[-*+]\s+', multiLine: true), '');
    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return cleaned.trim();
  }

  void resetSession() {
    _history.clear();
  }
}