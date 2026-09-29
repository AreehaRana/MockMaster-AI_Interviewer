import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mockmaster/common/widgets/m_gradient_background.dart';
import 'package:mockmaster/features/authentication/controllers/controllers_onboarding/onboarding_controllers.dart';
import 'package:mockmaster/utils/constants/image_strings.dart';
import 'package:mockmaster/utils/constants/text_strings.dart';
import 'package:mockmaster/utils/helpers/helper_function.dart';

import 'widgets/onboarding_page.dart';
import 'widgets/onboarding_skip_button.dart';
import 'widgets/onboarding_dot_navigation.dart';
import 'widgets/onboarding_next_button.dart';

class OnBoardingScreen extends StatelessWidget {
  OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());
    final dark = MHelperFunctions.isDarkMode(context);

    // Transparent scaffold — ombre paints behind the pages, no card box
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MGradientBackground(
        child: Stack(
          children: [
            // Horizontal pages
            PageView(
              controller: controller.pageController,
              onPageChanged: controller.updatePageIndicator,
              children: [
                OnBoardingPage(
                  image: dark
                      ? MImages.onBoardingImage1Dark
                      : MImages.onBoardingImage1Light,
                  title: MTexts.onBoardingTitle1,
                  subTitle: MTexts.onBoardingSubTitle1,
                ),
                OnBoardingPage(
                  image: dark
                      ? MImages.onBoardingImage2Dark
                      : MImages.onBoardingImage2Light,
                  title: MTexts.onBoardingTitle2,
                  subTitle: MTexts.onBoardingSubTitle2,
                ),
                OnBoardingPage(
                  image: dark
                      ? MImages.onBoardingImage3Dark
                      : MImages.onBoardingImage3Light,
                  title: MTexts.onBoardingTitle3,
                  subTitle: MTexts.onBoardingSubTitle3,
                ),
              ],
            ),

            // Skip button
            const OnBoardingSkip(),

            // Dot navigation
            const OnBoardingDotNavigation(),

            // Next button
            const OnBoardingNextButton(),
          ],
        ),
      ),
    );
  }
}