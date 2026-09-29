import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockmaster/features/personalization/models/user_model.dart';
import 'package:mockmaster/data/services/admin_firestore_services.dart';
import 'package:mockmaster/features/authentication/screens/admin/screens/admin_dashboard_screen.dart';

/// Drop this widget anywhere in your existing home/dashboard screen
/// (e.g. as a button in a drawer or app bar). It automatically hides
/// itself for non-admins and shows an "Admin Panel" button for admins.
/// Admin status is read reactively from Firestore's Role field — there
/// is no request/approval flow, so this either shows or it doesn't.
///
/// Example:
///   Drawer(
///     child: Column(
///       children: [
///         ...yourExistingItems,
///         const AdminEntryPoint(),
///       ],
///     ),
///   )
class AdminEntryPoint extends StatelessWidget {
  const AdminEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return StreamBuilder<UserModel?>(
      stream: AdminFirestoreService.instance.watchUser(uid),
      builder: (context, snapshot) {
        final user = snapshot.data;
        // Missing doc, missing Role, or Role != 'admin' -> hidden.
        if (user == null || !user.isAdmin) return const SizedBox.shrink();

        return ListTile(
          leading: const Icon(Icons.admin_panel_settings),
          title: const Text('Admin Panel'),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
            );
          },
        );
      },
    );
  }
}

/// App-bar-friendly version. Drop this in your Scaffold's AppBar actions
/// list. Renders nothing for normal users; shows a small shield icon
/// button for admins that opens the Admin Panel.
///
/// Example:
///   Scaffold(
///     appBar: AppBar(
///       title: const Text('Home'),
///       actions: const [AdminEntryPointIcon()],
///     ),
///     ...
///   )
class AdminEntryPointIcon extends StatelessWidget {
  const AdminEntryPointIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return StreamBuilder<UserModel?>(
      stream: AdminFirestoreService.instance.watchUser(uid),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null || !user.isAdmin) return const SizedBox.shrink();

        return IconButton(
          icon: const Icon(Icons.admin_panel_settings),
          tooltip: 'Admin Panel',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
            );
          },
        );
      },
    );
  }
}