import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mockmaster/common/widgets/m_glass_chip.dart';
import 'package:mockmaster/features/authentication/controllers/controllers_onboarding/onboarding_controllers.dart';
import 'package:mockmaster/utils/constants/sizes.dart';
import 'package:mockmaster/utils/device/device_utility.dart';

class OnBoardingNextButton extends StatefulWidget {
  const OnBoardingNextButton({super.key});

  @override
  State<OnBoardingNextButton> createState() => _OnBoardingNextButtonState();
}

class _OnBoardingNextButtonState extends State<OnBoardingNextButton> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: MSizes.defaultSpace,
      bottom: MDeviceUtils.getBottomNavigationBarHeight(),
      // Frosted glass circle with a press-scale animation instead of a solid fill
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.9),
        onTapCancel: () => setState(() => _scale = 1),
        onTapUp: (_) {
          setState(() => _scale = 1);
          OnBoardingController.instance.nextPage();
        },
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 150),
          child: MGlassChip(
            borderRadius: 100,
            padding: const EdgeInsets.all(14),
            child: const Icon(Iconsax.arrow_right_3),
          ),
        ),
      ),
    );
  }
}