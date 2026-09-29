import 'package:cloud_firestore/cloud_firestore.dart';

/// Who a chat message came from.
enum ChatSender { user, ai }

/// A single message in the MockMaster AI Assistant conversation, stored
/// at Users/{uid}/ChatMessages/{messageId}.
///
/// Mirrors the fromDoc/toMap pattern already used by [InterviewSession]
/// in interview_session_model.dart -- same capitalized Firestore field
/// naming convention ('Sender', 'Text', 'Timestamp').
class ChatMessageModel {
  final String id;
  final ChatSender sender;
  final String text;
  final DateTime timestamp;

  ChatMessageModel({
    required this.id,
    required this.sender,
    required this.text,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isUser => sender == ChatSender.user;

  factory ChatMessageModel.fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ChatMessageModel(
      id: doc.id,
      sender: (data['Sender'] as String? ?? 'ai') == 'user'
          ? ChatSender.user
          : ChatSender.ai,
      text: data['Text'] as String? ?? '',
      timestamp: (data['Timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Sender': sender == ChatSender.user ? 'user' : 'ai',
      'Text': text,
      'Timestamp': FieldValue.serverTimestamp(),
    };
  }
}
