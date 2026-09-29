import 'package:flutter/material.dart';
import 'manage_questions_screen.dart';
import 'manage_all_users_screen.dart';
import 'package:mockmaster/features/authentication/screens/admin/screens/manage_payment_screen.dart';

/// Only reachable by admins (gated by AdminEntryPoint / AdminEntryPointIcon,
/// which check Role == 'admin' in Firestore before ever navigating here).
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.people), text: 'All Users'),
              Tab(icon: Icon(Icons.quiz), text: 'Questions'),
              Tab(icon: Icon(Icons.payments), text: 'Payments'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ManageAllUsersScreen(),
            ManageQuestionsScreen(),
            ManagePaymentsScreen(),
          ],
        ),
      ),
    );
  }
}