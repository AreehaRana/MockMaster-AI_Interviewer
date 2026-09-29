import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mockmaster/common/widgets/m_glass_button.dart';
import 'package:mockmaster/features/authentication/screens/signup/signup.dart';
import 'package:mockmaster/utils/constants/sizes.dart';
import 'package:mockmaster/utils/constants/text_strings.dart';
import 'package:get/get.dart';
import 'package:mockmaster/features/authentication/screens/password_configuration/forget_password.dart';
import 'package:mockmaster/utils/validators/validation.dart';
import 'package:mockmaster/features/authentication/screens/login/login_controller.dart';

class MLoginForm extends StatefulWidget {
  const MLoginForm({super.key});

  @override
  State<MLoginForm> createState() => _MLoginFormState();
}

class _MLoginFormState extends State<MLoginForm> {
  late final LoginController controller;

  @override
  void initState() {
    super.initState();
    // A plain, LOCALLY-owned instance -- deliberately NOT registered with
    // GetX's global singleton registry (no Get.put/Get.find/Get.delete).
    // If this screen ever mounts twice in quick succession (e.g. timing
    // around an auth redirect), each mount now owns its own controller
    // instead of both fighting over one shared singleton -- which is
    // what caused "TextEditingController used after being disposed":
    // one MLoginForm's initState deleted the shared controller (and its
    // TextEditingControllers) while the other's TextFormFields were still
    // using them.
    controller = LoginController();
    controller.onInit();
  }

  @override
  void dispose() {
    controller.onClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MSizes.spaceBtwSections),
      child: Obx(
        () {
          // Same pattern as FeedbackScreen's loading state: swap the whole
          // form area for a centered spinner + text while signing in.
          if (controller.isLoading.value) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: MSizes.spaceBtwSections * 2),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Logging you in...'),
                  ],
                ),
              ),
            );
          }

          return Form(
            key: controller.loginFormKey,
            child: Column(
              children: [
                // Email field
                TextFormField(
                  controller: controller.email,
                  validator: (value) => MValidator.validateEmail(value),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.direct_right),
                    labelText: MTexts.email,
                  ),
                ),
                const SizedBox(height: MSizes.spaceBtwInputFields),

                // Password field with show/hide toggle
                Obx(
                  () => TextFormField(
                    controller: controller.password,
                    validator: (value) => MValidator.validatePassword(value),
                    obscureText: controller.hidePassword.value,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Iconsax.password_check),
                      labelText: MTexts.password,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.hidePassword.value
                              ? Iconsax.eye_slash
                              : Iconsax.eye,
                        ),
                        onPressed: () {
                          controller.hidePassword.value =
                              !controller.hidePassword.value;
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: MSizes.spaceBtwInputFields / 2),

                // Remember me + forget password row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Obx(
                          () => Checkbox(
                            value: controller.rememberMe.value,
                            onChanged: (value) {
                              controller.rememberMe.value = value ?? false;
                            },
                          ),
                        ),
                        const Text(MTexts.rememberMe),
                      ],
                    ),
                    TextButton(
                      onPressed: () => Get.to(() => const ForgetPassword()),
                      child: const Text(MTexts.forgetPassword),
                    ),
                  ],
                ),
                const SizedBox(height: MSizes.spaceBtwSections),

                // Sign in button -- glass animation button, same as hero banner / signup
                MGlassButton.filled(
                  label: MTexts.signIn,
                  icon: Icons.login_rounded,
                  onPressed: () => controller.emailAndPasswordSignIn(),
                ),
                const SizedBox(height: MSizes.spaceBtwItems),

                // Create account button -- glass animation button, outlined variant
                MGlassButton.outlined(
                  label: MTexts.createAccount,
                  icon: Icons.person_add_alt_1_rounded,
                  onPressed: () => Get.to(() => const SignupScreen()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}