import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mockmaster/features/authentication/screens/signup/signup_controller.dart';
import 'package:mockmaster/utils/constants/colors.dart';
import 'package:mockmaster/utils/constants/sizes.dart';
import 'package:mockmaster/utils/constants/text_strings.dart';
import 'package:mockmaster/utils/helpers/helper_function.dart';

class MTermsAndConditionsCheckbox extends StatelessWidget {
  const MTermsAndConditionsCheckbox({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SignupController.instance;
    final dark = MHelperFunctions.isDarkMode(context);

    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Obx(
            () => Checkbox(
              value: controller.privacyPolicy.value,
              onChanged: (value) {
                controller.privacyPolicy.value = value ?? false;
              },
            ),
          ),
        ),
        const SizedBox(width: MSizes.spaceBtwItems),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${MTexts.iAgreeTo} ',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                TextSpan(
                  text: '${MTexts.privacyPolicy} ',
                  style: Theme.of(context).textTheme.bodyMedium!.apply(
                        color: dark ? MColors.white : MColors.primaryColor,
                        decoration: TextDecoration.underline,
                        decorationColor:
                            dark ? MColors.white : MColors.primaryColor,
                      ),
                ),
                TextSpan(
                  text: '${MTexts.and} ',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                TextSpan(
                  text: MTexts.termsOfUse,
                  style: Theme.of(context).textTheme.bodyMedium!.apply(
                        color: dark ? MColors.white : MColors.primaryColor,
                        decoration: TextDecoration.underline,
                        decorationColor:
                            dark ? MColors.white : MColors.primaryColor,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}