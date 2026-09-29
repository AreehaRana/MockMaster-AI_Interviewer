import 'package:cloud_firestore/cloud_firestore.dart';

/// A single completed (or in-progress) interview attempt, stored at
/// Users/{uid}/InterviewSessions/{sessionId}.
///
/// Nothing writes to this collection yet — your interview-taking screens
/// need to call [InterviewSessionService.logCompletedInterview] when a
/// user finishes an interview. Until then, this will correctly show 0
/// interviews for everyone rather than crashing.
class InterviewSession {
  final String id;
  final String type; // e.g. "Technical", "HR", "Behavioral"
  final DateTime? completedAt;
  final int? score;

  InterviewSession({
    required this.id,
    required this.type,
    this.completedAt,
    this.score,
  });

  factory InterviewSession.fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return InterviewSession(
      id: doc.id,
      type: data['Type'] as String? ?? 'General',
      completedAt: (data['CompletedAt'] as Timestamp?)?.toDate(),
      score: data['Score'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Type': type,
      'Score': score,
      'CompletedAt': FieldValue.serverTimestamp(),
    };
  }
}
