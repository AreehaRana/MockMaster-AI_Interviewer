import 'package:flutter/material.dart';
import 'package:mockmaster/common/widgets/m_glass_chip.dart';
import 'package:mockmaster/features/authentication/controllers/controllers_onboarding/onboarding_controllers.dart';
import 'package:mockmaster/utils/constants/sizes.dart';
import 'package:mockmaster/utils/device/device_utility.dart';

class OnBoardingSkip extends StatelessWidget {
  const OnBoardingSkip({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MDeviceUtils.getAppBarHeight(),
      right: MSizes.defaultSpace,
      // Frosted glass pill instead of a plain text button
      child: MGlassChip(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: TextButton(
          onPressed: () => OnBoardingController.instance.skipPage(),
          child: const Text("Skip"),
        ),
      ),
    );
  }
}