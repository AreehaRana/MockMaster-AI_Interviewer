import 'package:cloud_firestore/cloud_firestore.dart';

/// One recorded successful payment for a Custom Interview.
class PaymentRecord {
  final String id;
  final String uid;
  final String userEmail;
  final double amount;
  final String interviewTitle;
  final DateTime? paidAt;

  PaymentRecord({
    required this.id,
    required this.uid,
    required this.userEmail,
    required this.amount,
    required this.interviewTitle,
    required this.paidAt,
  });

  factory PaymentRecord.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return PaymentRecord(
      id: doc.id,
      uid: data['uid'] as String? ?? '',
      userEmail: data['userEmail'] as String? ?? 'Unknown',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      interviewTitle: data['interviewTitle'] as String? ?? 'Custom Interview',
      paidAt: (data['paidAt'] as Timestamp?)?.toDate(),
    );
  }
}

/// Records every successful Custom Interview payment to Firestore under
/// a top-level `Payments` collection, and lets the admin panel read them
/// back. Call [recordPayment] right after a payment succeeds (see
/// CreateInterviewScreen); call [watchAllPayments] from the admin panel.
class PaymentService {
  PaymentService._();

  static final _payments = FirebaseFirestore.instance.collection('Payments');

  static Future<void> recordPayment({
    required String uid,
    required String userEmail,
    required double amount,
    required String interviewTitle,
  }) async {
    await _payments.add({
      'uid': uid,
      'userEmail': userEmail,
      'amount': amount,
      'interviewTitle': interviewTitle,
      'paidAt': FieldValue.serverTimestamp(),
    });
  }

  /// ADMIN-ONLY: every payment ever made, most recent first.
  static Stream<List<PaymentRecord>> watchAllPayments() {
    return _payments
        .orderBy('paidAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(PaymentRecord.fromDoc).toList());
  }
}