import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mockmaster/features/authentication/screens/login/login.dart';
import 'package:mockmaster/utils/constants/image_strings.dart';
import 'package:mockmaster/utils/constants/sizes.dart';
import 'package:mockmaster/utils/constants/text_strings.dart';
import 'package:mockmaster/utils/helpers/helper_function.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({
    super.key,
    this.image, 
    this.title = MTexts.yourAccountCreatedTitle,
    this.subTitle = MTexts.yourAccountCreatedSubTitle,
  });

  final String? image; 
  final String title;
  final String subTitle;

  @override
  Widget build(BuildContext context) {
    final dark = MHelperFunctions.isDarkMode(context); 

  
    final resolvedImage = image ??
        (dark
            ? MImages.staticSuccessIllustrationDark
            : MImages.staticSuccessIllustrationLight);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: MSizes.appBarHeight * 2,
            left: MSizes.defaultSpace,
            right: MSizes.defaultSpace,
            bottom: MSizes.defaultSpace,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Image
              Image(
                image: AssetImage(resolvedImage), 
                width: MHelperFunctions.screenWidth() * 0.6,
              ),

              const SizedBox(height: MSizes.spaceBtwSections),

              /// Title
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: MSizes.spaceBtwItems),

              /// Subtitle
              Text(
                subTitle,
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: MSizes.spaceBtwSections),

              /// Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.offAll(() => const LoginScreen()),
                  child: const Text(MTexts.continueText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}