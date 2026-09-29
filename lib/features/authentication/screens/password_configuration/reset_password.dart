import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mockmaster/utils/constants/image_strings.dart';
import 'package:mockmaster/utils/constants/sizes.dart';
import 'package:mockmaster/utils/constants/text_strings.dart';
import 'package:mockmaster/utils/helpers/helper_function.dart';
import 'package:mockmaster/common/widgets/m_gradient_background.dart';
import 'package:mockmaster/common/widgets/m_glass_card.dart';
import 'package:mockmaster/common/widgets/m_brand_header.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final dark = MHelperFunctions.isDarkMode(context);

    // Transparent scaffold + AppBar so the ombre gradient shows through everywhere.
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(CupertinoIcons.clear),
          ),
        ],
      ),
      body: MGradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: MGlassCard(
                // Card caps its own width, so the background stays visible around it.
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Small blended icon + "MockMaster" name, same as login/signup
                    const MBrandHeader(),
                    const SizedBox(height: MSizes.spaceBtwSections),

                    // Illustration swaps with theme
                    Image(
                      image: AssetImage(
                        dark
                            ? MImages.verifyIllustrationDark
                            : MImages.verifyIllustrationLight,
                      ),
                      width: MHelperFunctions.screenWidth() * 0.5,
                    ),
                    const SizedBox(height: MSizes.spaceBtwSections),

                    // Title
                    Text(
                      MTexts.changeYourPasswordTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: MSizes.spaceBtwItems),

                    // Subtitle
                    Text(
                      MTexts.changeYourPasswordSubTitle,
                      style: Theme.of(context).textTheme.labelMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: MSizes.spaceBtwSections),

                    // Continue / resend button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onPressed,
                        child: const Text(MTexts.resendEmail),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}