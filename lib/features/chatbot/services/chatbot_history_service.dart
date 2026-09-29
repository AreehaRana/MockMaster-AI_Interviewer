import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockmaster/features/chatbot/models/chat_message_model.dart';

/// Reads/writes the ChatMessages subcollection under each user.
///
/// Mirrors [InterviewSessionService] (interview_session_services.dart)
/// deliberately -- same singleton shape, same Users/{uid}/... nesting
/// style -- so the pattern is familiar to anyone reading this codebase.
///
/// Keeps one flat, ordered message list per user rather than the
/// multi-conversation ChatConversation/ChatMessage structure sketched in
/// the original spec: a single running MockMaster Assistant thread per
/// user is enough for this app's scope, and it's simpler to reason
/// about. If multiple named conversations are needed later, add a
/// ChatConversations collection above this one without changing
/// [ChatController]'s calling code.
class ChatbotHistoryService {
  ChatbotHistoryService._();
  static final ChatbotHistoryService instance = ChatbotHistoryService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _messagesFor(String uid) =>
      _db.collection('Users').doc(uid).collection('ChatMessages');

  /// One-time fetch of the existing conversation, oldest first, so it
  /// can be restored when the user reopens the chatbot.
  Future<List<ChatMessageModel>> fetchHistory(String uid) async {
    final snap =
        await _messagesFor(uid).orderBy('Timestamp', descending: false).get();
    return snap.docs.map(ChatMessageModel.fromDoc).toList();
  }

  /// Appends one message to the user's conversation.
  Future<void> appendMessage(String uid, ChatMessageModel message) async {
    await _messagesFor(uid).add(message.toMap());
  }

  /// Deletes the user's entire conversation (e.g. a "Clear chat" action).
  Future<void> clearHistory(String uid) async {
    final snap = await _messagesFor(uid).get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
