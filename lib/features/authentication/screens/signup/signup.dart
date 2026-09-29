import 'package:flutter/material.dart';
import 'package:mockmaster/features/authentication/screens/signup/widgets/signup_form.dart';
import 'package:mockmaster/utils/constants/text_strings.dart';
import 'package:mockmaster/common/widgets/m_gradient_background.dart';
import 'package:mockmaster/common/widgets/m_glass_card.dart';
import 'package:mockmaster/common/widgets/m_brand_header.dart';

import '../../../../utils/constants/sizes.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Small blended icon + "MockMaster" name, same as login/PrepWise reference
                    const MBrandHeader(),
                    const SizedBox(height: MSizes.spaceBtwSections),
                    Text(
                      MTexts.signupTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: MSizes.spaceBtwSections),
                    const MSignupForm(),
                    const SizedBox(height: MSizes.spaceBtwSections),
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