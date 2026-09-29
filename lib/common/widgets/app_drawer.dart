import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mockmaster/features/personalization/controllers/user_controller.dart';
import 'package:mockmaster/features/interview/services/interview_session_services.dart';
import 'package:mockmaster/features/interview/screen/interview_history_screen.dart';
import 'package:mockmaster/features/authentication/screens/admin/widgets/admin_entry_point.dart';
import 'package:mockmaster/data/repositories/repositories.authentication/authentication_repository.dart';
import 'package:mockmaster/utils/constants/colors.dart';
import 'package:mockmaster/utils/constants/sizes.dart';

/// App-wide navigation drawer. Now opened via [showBlurDrawer] (see
/// show_blur_drawer.dart) instead of Scaffold's built-in drawer, so the
/// screen behind it blurs. Includes an explicit close (X) button since
/// there's no more edge-swipe-to-dismiss affordance without the native
/// Scaffold drawer gesture.
class MAppDrawer extends StatelessWidget {
  const MAppDrawer({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    Navigator.of(context).pop(); // close the drawer first
    try {
      await AuthenticationRepository.instance.logout();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userController = UserController.instance;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: 304, // same width Flutter's default Drawer uses
        height: double.infinity,
        child: ClipRRect(
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(24),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? MColors.glassFillDark : MColors.glassFillLight,
                border: Border(
                  right: BorderSide(
                    color: isDark
                        ? MColors.glassBorderDark
                        : MColors.glassBorderLight,
                    width: 1.2,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? MColors.glassShadowDark
                        : MColors.glassShadowLight,
                    blurRadius: 24,
                    offset: const Offset(4, 0),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Close (X) button -- prominent, top-right of the drawer.
                    Padding(
                      padding: const EdgeInsets.fromLTRB(MSizes.md, MSizes.sm, MSizes.sm, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            tooltip: 'Close menu',
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        MSizes.md,
                        0,
                        MSizes.md,
                        MSizes.md,
                      ),
                      child: Obx(
                        () => Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.18),
                              child: Text(
                                userController.displayName.isNotEmpty
                                    ? userController.displayName[0]
                                        .toUpperCase()
                                    : '?',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ),
                            const SizedBox(width: MSizes.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    userController.user.value.username,
                                    style: Theme.of(context).textTheme.titleMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    userController.user.value.email,
                                    style: Theme.of(context).textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (uid != null)
                      StreamBuilder<int>(
                        stream: InterviewSessionService.instance
                            .watchInterviewCount(uid),
                        builder: (context, snapshot) {
                          final count = snapshot.data ?? 0;
                          return ListTile(
                            leading: const Icon(Icons.fact_check_outlined),
                            title: const Text('Interviews Completed'),
                            trailing: Text(
                              '$count',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            onTap: () {
                              Navigator.of(context).pop(); // close drawer first
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const InterviewHistoryScreen(),
                                ),
                              );
                            },
                          );
                        },
                      ),

                    const Divider(),

                    if (uid != null) ...[
                      const AdminEntryPoint(),
                      const Divider(),
                    ],

                    const Spacer(),

                    ListTile(
                      leading: const Icon(
                        Icons.logout,
                        color: Colors.red,
                      ),
                      title: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () => _handleLogout(context),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}