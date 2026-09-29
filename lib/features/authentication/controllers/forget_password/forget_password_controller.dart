import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mockmaster/data/repositories/repositories.authentication/authentication_repository.dart';
import 'package:mockmaster/features/authentication/screens/password_configuration/reset_password.dart';
import 'package:mockmaster/utils/constants/image_strings.dart';
import 'package:mockmaster/utils/network_manager/network_manager.dart';
import 'package:mockmaster/utils/popups/full_screen_loader.dart';
import 'package:mockmaster/utils/popups/loaders.dart';

class ForgetPasswordController extends GetxController {
  static ForgetPasswordController get instance => Get.find();

  // Form state
  final email = TextEditingController();
  final GlobalKey<FormState> forgetPasswordFormKey = GlobalKey<FormState>();

  /// Send reset password email
  Future<void> sendPasswordResetEmail() async {
    try {
      // Start loading
      MFullScreenLoader.openLoadingDialog(
        'Processing your request...',
        MImages.animationLoader,
      );

      // Check connectivity
      final isConnected = await MNetworkManager.instance.isConnected();
      if (!isConnected) {
        MFullScreenLoader.stopLoading();
        return;
      }

      // Validate form
      if (!forgetPasswordFormKey.currentState!.validate()) {
        MFullScreenLoader.stopLoading();
        return;
      }

      // Send reset email
      await AuthenticationRepository.instance.sendPasswordResetEmail(
        email.text.trim(),
      );

      // Stop loading
      MFullScreenLoader.stopLoading();

      // Show success message
      MLoaders.successSnackBar(
        title: 'Email Sent',
        message: 'Email Link Sent to Reset your Password',
      );

      // Redirect to reset password screen
      Get.to(
        () => ResetPasswordScreen(
          onPressed: () => resendPasswordResetEmail(email.text.trim()),
        ),
      );
    } catch (e) {
      // Stop loading and show error
      MFullScreenLoader.stopLoading();
      MLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// Resend reset password email
  Future<void> resendPasswordResetEmail(String email) async {
    try {
      // Start loading
      MFullScreenLoader.openLoadingDialog(
        'Processing your request...',
        MImages.animationLoader,
      );

      // Check connectivity
      final isConnected = await MNetworkManager.instance.isConnected();
      if (!isConnected) {
        MFullScreenLoader.stopLoading();
        return;
      }

      // Resend reset email
      await AuthenticationRepository.instance.sendPasswordResetEmail(email);

      // Stop loading
      MFullScreenLoader.stopLoading();

      // Show success message
      MLoaders.successSnackBar(
        title: 'Email Sent',
        message: 'Email Link Sent to Reset your Password Again',
      );
    } catch (e) {
      // Stop loading and show error
      MFullScreenLoader.stopLoading();
      MLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  @override
  void onClose() {
    email.dispose();
    super.onClose();
  }
}