import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mockmaster/common/widgets/m_glass_panel.dart';
import 'package:mockmaster/common/widgets/m_glass_button.dart';
import 'package:mockmaster/features/interview/screen/create_interview_screen.dart';
import 'package:mockmaster/features/personalization/controllers/user_controller.dart';
import 'package:mockmaster/utils/constants/image_strings.dart';
import 'package:mockmaster/utils/constants/sizes.dart';
import 'package:mockmaster/utils/constants/text_strings.dart';

class MHeroBanner extends StatelessWidget {
  const MHeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = UserController.instance;

    // Frosted glass panel instead of a flat tinted container
    return MGlassPanel(
      padding: const EdgeInsets.all(MSizes.lg),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          // Side-by-side layout only once there's enough width for both
          // the text column and the robot image without squeezing either.
          final isWide = width > 600;

          // Robot image height now scales continuously with the
          // available width (clamped to sane min/max) instead of jumping
          // between two fixed sizes right at the breakpoint -- this is
          // what stopped it from looking like it "shifted" oddly.
          final robotHeight = isWide
              ? (width * 0.16).clamp(120.0, 200.0)
              : (width * 0.34).clamp(90.0, 160.0);

          final textColumn = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Reactive greeting, updates whenever the signed-in user changes
              Obx(
                () => Text(
                  '${MTexts.greetingWelcome} ${userController.displayName} ',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: MSizes.xs),
              Text(
                MTexts.heroTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: MSizes.sm),
              Text(
                MTexts.heroSubTitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: MSizes.spaceBtwItems),
              MGlassButton.filled(
                label: MTexts.startAnInterview,
                icon: Icons.play_arrow_rounded,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CreateInterviewScreen(),
                    ),
                  );
                },
              ),
            ],
          );

          final robotImage = Image.asset(
            MImages.robotIllustration,
            height: robotHeight,
            fit: BoxFit.contain,
          );

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 3, child: textColumn),
                const SizedBox(width: MSizes.md),
                Expanded(flex: 2, child: Center(child: robotImage)),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textColumn,
              const SizedBox(height: MSizes.spaceBtwItems),
              Center(child: robotImage),
            ],
          );
        },
      ),
    );
  }
}