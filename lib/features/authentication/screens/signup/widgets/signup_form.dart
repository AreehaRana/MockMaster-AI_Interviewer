import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mockmaster/common/widgets/m_glass_button.dart';
import 'package:mockmaster/features/authentication/screens/signup/widgets/terms_and_condition_checkbox.dart';
import 'package:mockmaster/utils/constants/sizes.dart';
import 'package:mockmaster/utils/constants/text_strings.dart';
import 'package:get/get.dart';
import 'package:mockmaster/utils/validators/validation.dart';
import 'package:mockmaster/features/authentication/screens/signup/signup_controller.dart';

class MSignupForm extends StatelessWidget {
  const MSignupForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController()); // Initialize the controller
    return Form(
      key: controller.signupFormKey, // Assign the form key from the controller
      child: Column(
        children: [
          /// First & Last Name
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller.firstName, // Assign the controller for first name
                  validator: (value) => MValidator.validateName(value), // Proper name, no digits-only, no leading/trailing special chars
                  expands: false,
                  decoration: const InputDecoration(
                    labelText: MTexts.firstName,
                    prefixIcon: Icon(Iconsax.user),
                  ),
                ),
              ),
              const SizedBox(width: MSizes.spaceBtwInputFields),
              Expanded(
                child: TextFormField(
                  controller: controller.lastName, // Assign the controller for last name
                  validator: (value) => MValidator.validateName(value), // Same name rules as first name
                  expands: false,
                  decoration: const InputDecoration(
                    labelText: MTexts.lastName,
                    prefixIcon: Icon(Iconsax.user),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: MSizes.spaceBtwInputFields),

          /// Username
          TextFormField(
            controller: controller.username, // Assign the controller for username
            validator: (value) => MValidator.validateUsername(value), // No digits-only, no leading/trailing special chars
            expands: false,
            decoration: const InputDecoration(
              labelText: MTexts.username,
              prefixIcon: Icon(Iconsax.user_edit),
            ),
          ),
          const SizedBox(height: MSizes.spaceBtwInputFields),

          /// Email
          TextFormField(
            controller: controller.email, // Assign the controller for email
            validator: (value) => MValidator.validateEmail(value), // Validate email
            decoration: const InputDecoration(
              labelText: MTexts.email,
              prefixIcon: Icon(Iconsax.direct),
            ),
          ),
          const SizedBox(height: MSizes.spaceBtwInputFields),

          /// Password
          Obx(
            () => TextFormField(
              controller: controller.password, // Assign the controller for password
              validator: (value) => MValidator.validatePassword(value), // Validate password
              obscureText: controller.hidePassword.value, // Toggle password visibility
              decoration: InputDecoration(
                labelText: MTexts.password,
                prefixIcon: const Icon(Iconsax.password_check),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye,
                  ), // Change icon based on password visibility
                  onPressed: () => controller.hidePassword.value =
                      !controller.hidePassword.value, // Toggle password visibility
                ),
              ),
            ),
          ),
          const SizedBox(height: MSizes.spaceBtwSections),

          /// Terms & Conditions Checkbox
          const MTermsAndConditionsCheckbox(),
          const SizedBox(height: MSizes.spaceBtwSections),

          /// Sign Up Button
          MGlassButton.filled(
            label: MTexts.createAccount,
            icon: Icons.person_add_rounded,
            onPressed: () => controller.signup(),
          ),
        ],
      ),
    );
  }
}