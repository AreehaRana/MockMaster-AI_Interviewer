import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockmaster/features/personalization/models/user_model.dart';
import 'package:mockmaster/features/home/models/question_model.dart';

/// Central place for every Firestore read/write used by the admin panel.
///
/// Admin status is controlled ONLY through the `Role` field on each
/// user's Firestore document — there is no request/approval workflow.
/// An account becomes admin either by:
///   1. Manually editing Role to "admin" in Firestore Console, or
///   2. An existing admin promoting them via the "All Users" screen
///      (which itself just writes Role to Firestore).
class AdminFirestoreService {
  AdminFirestoreService._();
  static final AdminFirestoreService instance = AdminFirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('Users');

  CollectionReference<Map<String, dynamic>> get _questions =>
      _db.collection('Questions');

  // ---------------------------------------------------------------------
  // ROLE / PROFILE LOOKUP — call this after login to decide whether to
  // show the Admin Panel entry point in your app's home/dashboard screen.
  // ---------------------------------------------------------------------
  Future<UserModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromSnapshot(doc);
  }

  /// Reactive admin status — the source of truth for the entire admin UI.
  /// A missing document or missing Role field both resolve to non-admin.
  Stream<UserModel?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromSnapshot(doc);
    });
  }

  /// ADMIN-ONLY: list every account (for the "All Users" management view).
  Stream<List<UserModel>> watchAllUsers() {
    return _users
        .snapshots()
        .map((snap) => snap.docs.map(UserModel.fromSnapshot).toList());
  }

  /// ADMIN-ONLY: promote/demote — pass 'admin' or 'user'.
  /// Enforced server-side too: see firestore.rules, only an existing
  /// admin may write the Role field.
  Future<void> setUserRole(String uid, String role) async {
    await _users.doc(uid).update({'Role': role});
  }

  // ---------------------------------------------------------------------
  // QUESTIONS — admin can add / remove. Everyone else only reads.
  // ---------------------------------------------------------------------
  Stream<List<Question>> watchQuestions({String? categoryFilter}) {
    Query<Map<String, dynamic>> q = _questions;
    if (categoryFilter != null && categoryFilter.isNotEmpty) {
      q = q.where('Category', isEqualTo: categoryFilter);
    }
    return q.snapshots().map(
          (snap) => snap.docs.map(Question.fromDoc).toList(),
        );
  }

  Future<void> addQuestion(Question question) async {
    await _questions.add(question.toMap());
  }

  Future<void> deleteQuestion(String questionId) async {
    await _questions.doc(questionId).delete();
  }

  /// ONE-TIME MIGRATION: pushes your existing hardcoded question bank
  /// (from text_strings.dart) into Firestore. Safe to call more than
  /// once by accident — it checks first and does nothing if the
  /// Questions collection already has data, so you won't get duplicates.
  ///
  /// [bank] is a map of category label -> list of question strings,
  /// e.g. {'Software Engineer': [...], 'Data Analyst': [...]}.
  Future<int> migrateLegacyQuestionsIfEmpty(Map<String, List<String>> bank) async {
    final existing = await _questions.limit(1).get();
    if (existing.docs.isNotEmpty) {
      return 0; // already migrated (or already has data) — do nothing
    }

    final batch = _db.batch();
    int count = 0;
    bank.forEach((category, questions) {
      for (final text in questions) {
        final docRef = _questions.doc();
        batch.set(docRef, Question(id: '', text: text, category: category).toMap());
        count++;
      }
    });
    await batch.commit();
    return count;
  }
}