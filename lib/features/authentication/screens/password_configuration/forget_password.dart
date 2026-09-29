import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:mockmaster/features/authentication/controllers/forget_password/forget_password_controller.dart';
import 'package:mockmaster/utils/constants/sizes.dart';
import 'package:mockmaster/utils/constants/text_strings.dart';
import 'package:mockmaster/utils/validators/validation.dart';
import 'package:mockmaster/common/widgets/m_gradient_background.dart';
import 'package:mockmaster/common/widgets/m_glass_card.dart';
import 'package:mockmaster/common/widgets/m_brand_header.dart';
import 'package:mockmaster/common/widgets/m_glass_button.dart';

class ForgetPassword extends StatelessWidget {
  const ForgetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgetPasswordController());

    // Transparent scaffold + AppBar so the ombre gradient shows through everywhere.
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: MGradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: MGlassCard(
                // Card caps its own width, so the background stays visible around it.
                child: Form(
                  key: controller.forgetPasswordFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Small blended icon + "MockMaster" name, same as login/signup
                      const MBrandHeader(),
                      const SizedBox(height: MSizes.spaceBtwSections),
                      Text(
                        MTexts.forgetPasswordTitle,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: MSizes.spaceBtwItems),
                      Text(
                        MTexts.forgetPasswordSubTitle,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: MSizes.spaceBtwSections * 2),

                      // Email field
                      TextFormField(
                        controller: controller.email,
                        validator: (value) => MValidator.validateEmail(value),
                        decoration: const InputDecoration(
                          labelText: MTexts.email,
                          prefixIcon: Icon(Iconsax.direct_right),
                        ),
                      ),
                      const SizedBox(height: MSizes.spaceBtwSections),

                      // Submit button -- glass animation button, same as login/signup
                      MGlassButton.filled(
                        label: MTexts.submitText,
                        icon: Icons.send_rounded,
                        onPressed: () => controller.sendPasswordResetEmail(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}