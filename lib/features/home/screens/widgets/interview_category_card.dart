import 'package:flutter/material.dart';
import 'package:mockmaster/common/widgets/m_glass_panel.dart';
import 'package:mockmaster/common/widgets/m_glass_button.dart';
import 'package:mockmaster/features/home/models/interview_category_model.dart';
import 'package:mockmaster/features/home/screens/widgets/technology_badge.dart';
import 'package:mockmaster/features/interview/screen/interview_screen.dart';
import 'package:mockmaster/utils/constants/sizes.dart';
import 'package:mockmaster/utils/constants/text_strings.dart';

class MInterviewCategoryCard extends StatelessWidget {
  final InterviewCategoryModel category;

  const MInterviewCategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Frosted glass panel instead of a solid surface container
    return MGlassPanel(
      padding: const EdgeInsets.all(MSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + badge row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(MSizes.sm),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(category.icon, color: scheme.primary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: MSizes.sm,
                  vertical: MSizes.xs / 2,
                ),
                decoration: BoxDecoration(
                  color: category.isTechnical
                      ? scheme.primary.withValues(alpha: 0.15)
                      : scheme.secondary.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(MSizes.borderRadiusSm),
                ),
                child: Text(
                  category.badge,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: MSizes.spaceBtwItems),

          // Title
          Text(
            category.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: MSizes.xs),

          // Description
          Text(
            category.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: MSizes.spaceBtwItems),

          // Technology badges
          Wrap(
            spacing: MSizes.xs,
            runSpacing: MSizes.xs,
            children: category.technologies
                .map((tech) => MTechnologyBadge(label: tech))
                .toList(),
          ),
          const SizedBox(height: MSizes.spaceBtwItems),

          // Take interview button
          MGlassButton.filled(
            label: MTexts.takeInterview,
            icon: Icons.arrow_forward_rounded,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => InterviewScreen(
                    title: category.title,
                    questions: category.questions,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}