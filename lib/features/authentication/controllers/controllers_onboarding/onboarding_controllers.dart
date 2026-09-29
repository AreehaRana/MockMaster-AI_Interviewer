import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mockmaster/features/authentication/screens/login/login.dart';
import 'package:get_storage/get_storage.dart';

class OnBoardingController extends GetxController {
  // Singleton access: OnBoardingController.instance
  static OnBoardingController get instance => Get.find();

  // Controller to manage the PageView and control page navigation
  final PageController pageController = PageController();

  // Observable variable to track the current page index (starts at 0)
  Rx<int> currentPageIndex = 0.obs;

  // Update current index when a page is swiped/changed
  void updatePageIndicator(int index) {
    currentPageIndex.value = index;
  }

  // Jump directly to a specific dot's page when a dot is tapped
  void dotNavigationClick(int index) {
    currentPageIndex.value = index;
    pageController.jumpToPage(index);
  }

  // Move to the next page smoothly
  void nextPage() {
    if (currentPageIndex.value == 2) {
      final storage = GetStorage();
      if(kDebugMode){
        print("GET STORAGE NEXT BUTTON");
        print(storage.read('IsFirstTime'));
      }

      storage.writeIfNull('IsFirstTime', false);
      if(kDebugMode){
        print("GET STORAGE NEXT BUTTON");
        print(storage.read('IsFirstTime'));
      }
      ///Get.to(LoginScreen());
      // Last page reached — navigate to Login/Home screen
      Get.offAll(() => const LoginScreen());
    } else {
      final page = currentPageIndex.value + 1;
      pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  // Skip directly to the last page (or navigate away entirely)
  void skipPage() {
    // Option A: jump to last onboarding page
    pageController.jumpToPage(2);

    // Option B (more common): skip straight to Login/Home screen instead
    // Get.offAll(() => const LoginScreen());
  }
}
