import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:mockmaster/data/repositories/repositories.authentication/authentication_repository.dart';
import 'package:mockmaster/features/home/screens/home_screen.dart';
import 'package:mockmaster/features/interview/screen/create_interview_screen.dart';
import 'package:mockmaster/features/personalization/controllers/user_controller.dart';
import 'package:mockmaster/utils/constants/colors.dart';
import 'package:mockmaster/utils/helpers/helper_function.dart';

/// Bottom-navigation shell for the app's main tabs.
/// Adapted from a t_store-style reference into mockmaster's own screens.
class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final darkMode = MHelperFunctions.isDarkMode(context);

    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) =>
              controller.selectedIndex.value = index,
          backgroundColor: darkMode ? MColors.black : Colors.white,
          indicatorColor: darkMode
              ? MColors.white.withOpacity(0.1)
              : MColors.black.withOpacity(0.1),
          destinations: const [
            NavigationDestination(icon: Icon(Iconsax.home), label: 'Home'),
            NavigationDestination(
              icon: Icon(Iconsax.microphone_2),
              label: 'Interview',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.user),
              label: 'Profile',
            ),
          ],
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  static NavigationController get instance => Get.find();

  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    const HomeScreen(),
    const CreateInterviewScreen(),
    const _ProfileTab(),
  ];
}

/// Lightweight placeholder Profile tab: shows the signed-in user's name
/// and a logout button. Swap this out once a dedicated profile/settings
/// screen exists in the project.
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final userController = Get.put(UserController());

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.user, size: 64),
            const SizedBox(height: 16),
            Obx(
              () => Text(
                userController.displayName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => AuthenticationRepository.instance.logout(),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}