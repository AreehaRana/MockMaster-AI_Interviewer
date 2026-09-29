import 'package:flutter/material.dart';
import 'package:mockmaster/features/personalization/models/user_model.dart';
import 'package:mockmaster/data/services/admin_firestore_services.dart';


class ManageAllUsersScreen extends StatelessWidget {
  const ManageAllUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = AdminFirestoreService.instance;

    return StreamBuilder<List<UserModel>>(
      stream: service.watchAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final users = snapshot.data ?? [];
        if (users.isEmpty) {
          return const Center(child: Text('No users yet.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: users.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final user = users[index];
            return Card(
              child: ListTile(
                title: Text(user.fullName.trim().isEmpty ? user.email : user.fullName),
                subtitle: Text(user.email),
                trailing: Chip(
                  label: Text(user.isAdmin ? 'Admin' : 'User'),
                  backgroundColor:
                      user.isAdmin ? Colors.green.shade100 : Colors.grey.shade200,
                ),
                onTap: () => _showRoleDialog(context, service, user),
              ),
            );
          },
        );
      },
    );
  }

  void _showRoleDialog(
    BuildContext context,
    AdminFirestoreService service,
    UserModel user,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(user.fullName.trim().isEmpty ? user.email : user.fullName),
        content: Text('Current role: ${user.isAdmin ? "Admin" : "User"}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          if (user.isAdmin)
            TextButton(
              onPressed: () async {
                await service.setUserRole(user.id, 'user');
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Demote to User'),
            )
          else
            TextButton(
              onPressed: () async {
                await service.setUserRole(user.id, 'admin');
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Promote to Admin'),
            ),
        ],
      ),
    );
  }
}
