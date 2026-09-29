import 'package:flutter/material.dart';
import 'package:mockmaster/utils/constants/sizes.dart';
import 'package:mockmaster/common/widgets/m_gradient_background.dart';
import 'package:mockmaster/common/widgets/m_glass_card.dart';

import 'widgets/login_header.dart';
import 'widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Transparent scaffold lets the ombre gradient paint behind the glass card.
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MGradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: MGlassCard(
                // Card caps its own width, so the background stays visible around it.
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const MLoginHeader(),
                    const MLoginForm(),
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