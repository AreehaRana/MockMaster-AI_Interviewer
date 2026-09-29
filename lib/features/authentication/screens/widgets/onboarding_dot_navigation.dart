import 'package:flutter/material.dart';
import 'package:mockmaster/common/widgets/m_glass_chip.dart';
import 'package:mockmaster/features/authentication/controllers/controllers_onboarding/onboarding_controllers.dart';
import 'package:mockmaster/utils/constants/colors.dart';
import 'package:mockmaster/utils/constants/sizes.dart';
import 'package:mockmaster/utils/device/device_utility.dart';
import 'package:mockmaster/utils/helpers/helper_function.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingDotNavigation extends StatelessWidget {
  const OnBoardingDotNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = MHelperFunctions.isDarkMode(context);
    final controller = OnBoardingController.instance;

    return Positioned(
      left: MSizes.defaultSpace,
      bottom: MDeviceUtils.getBottomNavigationBarHeight() + 25,
      // Frosted pill keeps the dots readable over any background
      child: MGlassChip(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: SmoothPageIndicator(
          controller: controller.pageController,
          count: 3,
          onDotClicked: controller.dotNavigationClick,
          effect: ExpandingDotsEffect(
            activeDotColor: dark ? MColors.light : MColors.dark,
            dotHeight: 6,
          ),
        ),
      ),
    );
  }
}