import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:mockmaster/data/repositories/repositories.authentication/authentication_repository.dart';
import 'package:mockmaster/utils/network_manager/network_manager.dart';
import 'package:mockmaster/utils/popups/loaders.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  // Form state
  final rememberMe = false.obs;
  final hidePassword = true.obs;
  final isLoading = false.obs; // drives the feedback-screen-style inline loader
  final localStorage = GetStorage();
  final email = TextEditingController();
  final password = TextEditingController();

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    // Pre-fill remembered credentials if the user opted in previously.
    email.text = localStorage.read('REMEMBER_ME_EMAIL') ?? '';
    password.text = localStorage.read('REMEMBER_ME_PASSWORD') ?? '';
    if (email.text.isNotEmpty) rememberMe.value = true;
    super.onInit();
  }

  /// Email and password sign-in flow.
  Future<void> emailAndPasswordSignIn() async {
    try {
      // Start loading -- swaps the form UI for a spinner, same as FeedbackScreen.
      isLoading.value = true;

      // Check connectivity
      final isConnected = await MNetworkManager.instance.isConnected();
      if (!isConnected) {
        isLoading.value = false;
        return;
      }

      // Validate form
      if (!loginFormKey.currentState!.validate()) {
        isLoading.value = false;
        return;
      }

      // Save or clear remember-me data
      if (rememberMe.value) {
        localStorage.write('REMEMBER_ME_EMAIL', email.text.trim());
        localStorage.write('REMEMBER_ME_PASSWORD', password.text.trim());
      } else {
        localStorage.remove('REMEMBER_ME_EMAIL');
        localStorage.remove('REMEMBER_ME_PASSWORD');
      }

      // Authenticate
      await AuthenticationRepository.instance.loginWithEmailAndPassword(
        email.text.trim(),
        password.text.trim(),
      );

      // Stop loader, then redirect
      isLoading.value = false;
      AuthenticationRepository.instance.screenRedirect();
    } catch (e) {
      isLoading.value = false;
      MLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    super.onClose();
  }
} 