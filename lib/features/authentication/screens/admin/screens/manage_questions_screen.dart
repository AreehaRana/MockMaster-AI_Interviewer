import 'package:flutter/material.dart';
import 'package:mockmaster/features/home/models/question_model.dart';
import 'package:mockmaster/data/services/admin_firestore_services.dart';
import 'add_edit_question_screen.dart';
import '../legacy_question_bank.dart';

class ManageQuestionsScreen extends StatefulWidget {
  const ManageQuestionsScreen({super.key});

  @override
  State<ManageQuestionsScreen> createState() => _ManageQuestionsScreenState();
}

class _ManageQuestionsScreenState extends State<ManageQuestionsScreen> {
  final service = AdminFirestoreService.instance;
  String? _categoryFilter;
  bool _migrating = false;

  Future<void> _runMigration() async {
    setState(() => _migrating = true);
    try {
      final added = await service.migrateLegacyQuestionsIfEmpty(legacyQuestionBank);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              added > 0
                  ? 'Imported $added questions from the local question bank.'
                  : 'Nothing imported — Firestore already has questions.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _migrating = false);
    }
  }

  // Distinct colors per category so cards are visually easy to scan,
  // cycling through a fixed palette by the category's hash.
  Color _categoryColor(String category, ColorScheme scheme) {
    final palette = [
      scheme.primaryContainer,
      Colors.orange.shade100,
      Colors.teal.shade100,
      Colors.purple.shade100,
      Colors.blue.shade100,
      Colors.pink.shade100,
    ];
    final index = category.hashCode.abs() % palette.length;
    return palette[index];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Filter by category (optional)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) => setState(() => _categoryFilter = value),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _migrating ? null : _runMigration,
                  icon: _migrating
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_upload_outlined),
                  label: const Text('Import bank'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Question>>(
              stream: service.watchQuestions(categoryFilter: _categoryFilter),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final questions = snapshot.data ?? [];
                if (questions.isEmpty) {
                  return const Center(
                    child: Text(
                      'No questions yet.\nTap + to add one, or "Import bank" to load your existing question bank.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                // Card grid instead of a flat list -- 2 columns on wide
                // screens (tablet/web), 1 column on phones.
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 700 ? 2 : 1;
                    return GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: crossAxisCount == 1 ? 3.4 : 3.0,
                      ),
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        final q = questions[index];
                        final catColor = _categoryColor(q.category, scheme);

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: scheme.outlineVariant),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: catColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      q.category,
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => _confirmDelete(context, q),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Text(
                                  q.text,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddEditQuestionScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Card'),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Question q) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete question?'),
        content: Text(q.text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await service.deleteQuestion(q.id);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}