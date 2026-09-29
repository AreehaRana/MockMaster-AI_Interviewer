import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mockmaster/utils/constants/image_strings.dart';
import 'package:mockmaster/utils/constants/colors.dart';
import 'package:mockmaster/utils/helpers/helper_function.dart';
import 'package:mockmaster/common/loaders/animation_loader.dart';

/// A utility class for managing a full-screen loading dialog.
class MFullScreenLoader {
  /// Open a full-screen loading dialog with a given text and animation.
  ///
  /// Parameters:
  /// - [text]: The text to be displayed in the loading dialog.
  /// - [animation]: The Lottie animation to be shown.
  static void openLoadingDialog(String text, String animation) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Container(
          color: MHelperFunctions.isDarkMode(Get.context!)
              ? MColors.dark
              : MColors.white,
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 250),
              MAnimationLoaderWidget(
                text: text,
                animation: animation,
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Close the full-screen loading dialog.
  static void stopLoading() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}