import 'package:cloud_firestore/cloud_firestore.dart';

/// A single open-ended interview question, grouped by category
/// (e.g. "Software Engineer", "Data Analyst"). No multiple-choice
/// options or correct answer — these are prompts the user answers
/// out loud / in free text during a mock interview.
class Question {
  final String id;
  final String text;
  final String category;
  final DateTime? createdAt;
  final String createdBy; // uid of admin who added it ('' for imported ones)

  Question({
    required this.id,
    required this.text,
    required this.category,
    this.createdAt,
    this.createdBy = '',
  });

  factory Question.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Question(
      id: doc.id,
      text: data['Text'] as String? ?? '',
      category: data['Category'] as String? ?? 'General',
      createdAt: (data['CreatedAt'] as Timestamp?)?.toDate(),
      createdBy: data['CreatedBy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Text': text,
      'Category': category,
      'CreatedBy': createdBy,
      'CreatedAt': FieldValue.serverTimestamp(),
    };
  }
}