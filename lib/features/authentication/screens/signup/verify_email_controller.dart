import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'package:mockmaster/common/widgets_login_signup/success_screen/success_screen.dart';
import 'package:mockmaster/data/repositories/repositories.authentication/authentication_repository.dart';
import 'package:mockmaster/utils/constants/image_strings.dart';
import 'package:mockmaster/utils/constants/text_strings.dart';
import 'package:mockmaster/utils/popups/loaders.dart';

class VerifyEmailController extends GetxController {
  static VerifyEmailController get instance => Get.find();

  Timer? _autoRedirectTimer;

  /// Send Email whenever the Verify screen appears, and start the
  /// timer that auto-redirects once the user verifies their email.
  @override
  void onInit() {
    sendEmailVerification();
    setTimerForAutoRedirect();
    super.onInit();
  }

  /// Cancel the timer when this controller is disposed so it doesn't
  /// keep firing after the user leaves this screen.
  @override
  void onClose() {
    _autoRedirectTimer?.cancel();
    super.onClose();
  }

  /// Send Email Verification Link
  Future<void> sendEmailVerification() async {
    try {
      await AuthenticationRepository.instance.sendEmailVerification();
      MLoaders.successSnackBar(
        title: 'Email Sent',
        message: 'Please check your inbox and verify your email.',
      );
    } catch (e) {
      MLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// Timer to automatically redirect once the email is verified
  void setTimerForAutoRedirect() {
    _autoRedirectTimer = Timer.periodic(const Duration(seconds: 1), (
      timer,
    ) async {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if (user?.emailVerified ?? false) {
        timer.cancel();
        Get.off(
          () => const SuccessScreen(
            image: MImages.staticSuccessIllustrationLight,
            title: MTexts.yourAccountCreatedTitle,
            subTitle: MTexts.yourAccountCreatedSubTitle,
          ),
        );
      }
    });
  }

  /// Manually check if email is verified
  Future<void> checkEmailVerification() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.emailVerified) {
      Get.off(
        () => const SuccessScreen(
          image: MImages.staticSuccessIllustrationLight,
          title: MTexts.yourAccountCreatedTitle,
          subTitle: MTexts.yourAccountCreatedSubTitle,
        ),
      );
    }
  }
}