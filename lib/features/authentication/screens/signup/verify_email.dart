import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mockmaster/data/repositories/repositories.authentication/authentication_repository.dart';
import 'package:mockmaster/features/authentication/screens/signup/verify_email_controller.dart';
import 'package:mockmaster/utils/constants/image_strings.dart';
import 'package:mockmaster/utils/constants/sizes.dart';
import 'package:mockmaster/utils/constants/text_strings.dart';
import 'package:mockmaster/utils/helpers/helper_function.dart';
import 'package:mockmaster/common/widgets/m_gradient_background.dart';
import 'package:mockmaster/common/widgets/m_glass_card.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key, this.email});
  final String? email;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VerifyEmailController());
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
            onPressed: () => AuthenticationRepository.instance.logout(),
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

                    // Title & subtitle
                    Text(
                      MTexts.confirmEmail,
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: MSizes.spaceBtwItems),
                    Text(
                      email ?? '',
                      style: Theme.of(context).textTheme.labelLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: MSizes.spaceBtwItems),
                    Text(
                      MTexts.confirmEmailSubTitle,
                      style: Theme.of(context).textTheme.labelMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: MSizes.spaceBtwSections),

                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => controller.checkEmailVerification(),
                        child: const Text(MTexts.continueText),
                      ),
                    ),
                    const SizedBox(height: MSizes.spaceBtwItems),

                    // Resend email button
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => controller.sendEmailVerification(),
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