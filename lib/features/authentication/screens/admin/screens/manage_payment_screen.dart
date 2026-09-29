import 'package:flutter/material.dart';
import 'package:mockmaster/data/services/payment_service.dart';

/// ADMIN-ONLY: shows every successful Custom Interview payment --
/// who paid, how much, and when. Read-only.
class ManagePaymentsScreen extends StatelessWidget {
  const ManagePaymentsScreen({super.key});

  String _formatDate(DateTime? date) {
    if (date == null) return 'Just now';
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PaymentRecord>>(
      stream: PaymentService.watchAllPayments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final payments = snapshot.data ?? [];
        if (payments.isEmpty) {
          return const Center(child: Text('No payments yet.'));
        }

        final total = payments.fold<double>(0, (sum, p) => sum + p.amount);

        return Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${payments.length} payment${payments.length == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Rs. ${total.toStringAsFixed(0)} total',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: payments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final p = payments[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.receipt_long_rounded),
                      title: Text(p.userEmail),
                      subtitle: Text(
                        '${p.interviewTitle} • ${_formatDate(p.paidAt)}',
                      ),
                      trailing: Text(
                        'Rs. ${p.amount.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}