import 'package:cloud_firestore/cloud_firestore.dart';

/// One completed interview session's saved summary.
class InterviewSessionModel {
  final String id;
  final String interviewTitle;
  final int overallScore;
  final int totalQuestions;
  final int answeredQuestions;
  final DateTime? completedAt;

  InterviewSessionModel({
    required this.id,
    required this.interviewTitle,
    required this.overallScore,
    required this.totalQuestions,
    required this.answeredQuestions,
    required this.completedAt,
  });

  factory InterviewSessionModel.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return InterviewSessionModel(
      id: doc.id,
      interviewTitle: data['interviewTitle'] as String? ?? 'Interview',
      overallScore: (data['overallScore'] as num?)?.toInt() ?? 0,
      totalQuestions: (data['totalQuestions'] as num?)?.toInt() ?? 0,
      answeredQuestions: (data['answeredQuestions'] as num?)?.toInt() ?? 0,
      // completedAt is set via FieldValue.serverTimestamp(), so it can be
      // null for a brief moment right after being written, before the
      // server timestamp round-trips back down.
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }
}

/// Tracks completed interview sessions per user in Firestore, under:
/// Users/{uid}/InterviewSessions/{sessionId}
///
/// Used by MAppDrawer to show a live "Interviews Completed" count via
/// [watchInterviewCount], and by InterviewHistoryScreen to show the full
/// list of which interviews were taken via [watchSessions].
/// [recordSession] is called from FeedbackScreen once grading finishes.
class InterviewSessionService {
  InterviewSessionService._();
  static final InterviewSessionService instance = InterviewSessionService._();

  final _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _sessionsRef(String uid) {
    return _firestore.collection('Users').doc(uid).collection('InterviewSessions');
  }

  /// Real-time count of completed interviews for this user. Drawer widgets
  /// wrap this in a StreamBuilder<int> so the number updates live without
  /// needing to reopen the drawer.
  Stream<int> watchInterviewCount(String uid) {
    return _sessionsRef(uid).snapshots().map((snapshot) => snapshot.docs.length);
  }

  /// Real-time list of every completed interview for this user, most
  /// recent first -- powers InterviewHistoryScreen so the user can see
  /// exactly WHICH interviews they took, not just how many.
  Stream<List<InterviewSessionModel>> watchSessions(String uid) {
    return _sessionsRef(uid)
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(InterviewSessionModel.fromDoc).toList());
  }

  /// Saves a completed interview session's summary so it counts toward
  /// the total and shows up in the history list. Call this from
  /// FeedbackScreen once grading finishes.
  Future<void> recordSession({
    required String uid,
    required String interviewTitle,
    required int overallScore,
    required int totalQuestions,
    required int answeredQuestions,
  }) async {
    await _sessionsRef(uid).add({
      'interviewTitle': interviewTitle,
      'overallScore': overallScore,
      'totalQuestions': totalQuestions,
      'answeredQuestions': answeredQuestions,
      'completedAt': FieldValue.serverTimestamp(),
    });
  }
}