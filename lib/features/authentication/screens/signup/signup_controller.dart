import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mockmaster/data/repositories/repositories.authentication/authentication_repository.dart';
import 'package:mockmaster/data/repositories/user/user_repository.dart';
import 'package:mockmaster/features/authentication/screens/signup/verify_email.dart';
import 'package:mockmaster/features/personalization/models/user_model.dart';
import 'package:mockmaster/utils/constants/image_strings.dart';
import 'package:mockmaster/utils/network_manager/network_manager.dart';
import 'package:mockmaster/utils/popups/full_screen_loader.dart';
import 'package:mockmaster/utils/popups/loaders.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();

  // Form state — phoneNumber removed, form no longer collects it
  final privacyPolicy = true.obs;
  final hidePassword = true.obs;

  final email = TextEditingController();
  final lastName = TextEditingController();
  final username = TextEditingController();
  final password = TextEditingController();
  final firstName = TextEditingController();

  final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  /// Signup flow
  Future<void> signup() async {
    try {
      // Start loading
      MFullScreenLoader.openLoadingDialog(
        'We are processing your information...',
        MImages.animationLoader,
      );

      // Check connectivity
      final isConnected = await MNetworkManager.instance.isConnected();
      if (!isConnected) {
        MFullScreenLoader.stopLoading();
        return;
      }

      // Validate form
      if (!signupFormKey.currentState!.validate()) {
        MFullScreenLoader.stopLoading();
        return;
      }

      // Privacy policy must be accepted
      if (!privacyPolicy.value) {
        MFullScreenLoader.stopLoading();
        MLoaders.warningSnackBar(
          title: 'Please accept the privacy policy',
          message:
              'You must accept the privacy policy to proceed with signup.',
        );
        return;
      }

      // Register user in Firebase Authentication
      final UserCredential userCredential =
          await AuthenticationRepository.instance
              .registerWithEmailAndPassword(
        email.text.trim(),
        password.text.trim(),
      );

      // Build user model — phoneNumber left empty since it's no longer collected
      final newUser = UserModel(
        id: userCredential.user!.uid,
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        username: username.text.trim(),
        email: email.text.trim(),
        phoneNumber: '',
      );

      // Save user record in Firestore
      final userRepository = Get.put(UserRepository());
      await userRepository.saveUserRecord(newUser);

      // Stop loading
      MFullScreenLoader.stopLoading();

      // Show success message
      MLoaders.successSnackBar(
        title: 'Congratulations',
        message:
            'Your account has been created! Verify your email to continue.',
      );

      // Move to verify email screen
      Get.to(() => VerifyEmailScreen(email: email.text.trim()));
    } catch (e) {
      // Stop loading and show error
      MFullScreenLoader.stopLoading();
      MLoaders.errorSnackBar(title: 'Signup Error', message: e.toString());
    }
  }

  /// Dispose controllers
  @override
  void onClose() {
    email.dispose();
    lastName.dispose();
    username.dispose();
    password.dispose();
    firstName.dispose();
    super.onClose();
  }
}