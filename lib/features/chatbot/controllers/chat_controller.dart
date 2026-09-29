import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'package:mockmaster/features/chatbot/models/chat_message_model.dart';
import 'package:mockmaster/features/chatbot/services/chatbot_ai_services.dart';
import 'package:mockmaster/features/chatbot/services/chatbot_history_service.dart';
import 'package:mockmaster/features/personalization/controllers/user_controller.dart';
import 'package:mockmaster/utils/constants/text_Strings.dart';

/// Drives the MockMaster AI Assistant chat screen.
///
/// GetxController (not ChangeNotifier) to match every other controller
/// in this project. Registered with `Get.put(ChatController())` directly
/// inside ChatbotScreen's build(), the same way HomeScreen does
/// `Get.put(UserController())` -- this project doesn't use route-based
/// GetX bindings for feature controllers, so there's no reason to start
/// here.
class ChatController extends GetxController {
  static ChatController get instance => Get.find();

  final RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  final RxBool isSending = false.obs;

  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    _restoreOrWelcome();
  }

  @override
  void onClose() {
    // Wipe the saved conversation the moment the user leaves this screen,
    // so re-entering the chatbot always starts a fresh session instead of
    // restoring the previous one.
    _clearHistoryOnExit();
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  /// Deletes the signed-in user's saved conversation on exit. Fire-and-
  /// forget: onClose() shouldn't block navigation waiting on a Firestore
  /// delete, and a failure here just means the next restore finds stale
  /// messages -- not worth surfacing an error for.
  void _clearHistoryOnExit() {
    final uid = _uid;
    if (uid == null) return; // Guests never had persisted history anyway.
    ChatbotHistoryService.instance.clearHistory(uid).catchError(
      (e) => debugPrint('MockMaster AI Assistant: failed to clear history: $e'),
    );
  }

  /// Loads any saved conversation for the signed-in user; falls back to
  /// a fresh welcome message for guests, first-time chatters, or anyone
  /// whose previous session was already cleared on exit.
  Future<void> _restoreOrWelcome() async {
    final uid = _uid;
    if (uid != null) {
      try {
        final history = await ChatbotHistoryService.instance.fetchHistory(uid);
        if (history.isNotEmpty) {
          messages.assignAll(history);
          _scrollToBottomSoon();
          return;
        }
      } catch (e) {
        debugPrint('MockMaster AI Assistant: failed to load history: $e');
      }
    }
    _addAiMessage(MTexts.chatbotWelcomeMessage, persist: false);
  }

  /// Sends whatever is currently typed in [textController].
  Future<void> sendCurrentInput() async {
    final text = textController.text;
    await sendMessage(text);
  }

  /// Sends a suggestion chip's canned prompt as if the user typed it.
  Future<void> sendSuggestion(String prompt) => sendMessage(prompt);

  /// Core send flow: validates input, shows the user's bubble, calls the
  /// AI service, and shows the reply (or a friendly error).
  Future<void> sendMessage(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty || isSending.value) return;

    _addUserMessage(text);
    textController.clear();

    isSending.value = true;
    try {
      final reply = await ChatbotAiService.instance.sendMessage(
        text,
        userContext: _buildUserContext(),
      );
      _addAiMessage(reply);
    } catch (e) {
      debugPrint('MockMaster AI Assistant: send failed: $e');
      _addAiMessage(MTexts.chatbotErrorMessage, persist: false);
    } finally {
      isSending.value = false;
    }
  }

  /// Builds a factual-only context block for the AI service. Only real,
  /// currently-available data goes in here -- per the project spec, the
  /// chatbot must never be handed (or invent) fabricated scores or
  /// performance history.
  String _buildUserContext() {
    final buffer = StringBuffer();
    buffer.writeln('Name: ${UserController.instance.displayName}');

    final uid = _uid;
    if (uid == null) {
      buffer.writeln('Signed in: no (guest session)');
    }
    // Real interview-count data, when available, is streamed into the
    // drawer via InterviewSessionService.watchInterviewCount. We don't
    // block sending a chat message on an extra Firestore read here, so
    // per-message performance data (scores, weak topics) is only added
    // once that data actually exists in InterviewSession docs -- see
    // the TODO in interview_session_services.dart. Until an interview
    // flow actually calls logCompletedInterview, there is nothing real
    // to attach, and the system prompt already instructs the model to
    // say so honestly rather than guess.
    return buffer.toString();
  }

  void _addUserMessage(String text) {
    final message = ChatMessageModel(id: _newId(), sender: ChatSender.user, text: text);
    messages.add(message);
    _persist(message);
    _scrollToBottomSoon();
  }

  void _addAiMessage(String text, {bool persist = true}) {
    final message = ChatMessageModel(id: _newId(), sender: ChatSender.ai, text: text);
    messages.add(message);
    if (persist) _persist(message);
    _scrollToBottomSoon();
  }

  void _persist(ChatMessageModel message) {
    final uid = _uid;
    if (uid == null) return; // Guests: in-memory only for this session.
    ChatbotHistoryService.instance.appendMessage(uid, message).catchError(
      (e) => debugPrint('MockMaster AI Assistant: failed to save message: $e'),
    );
  }

  void _scrollToBottomSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();
}