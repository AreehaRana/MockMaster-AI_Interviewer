import 'package:flutter/material.dart';
import 'package:mockmaster/utils/constants/sizes.dart';

/// One tappable suggestion button shown under the welcome message
/// (e.g. "Prepare for an Interview"). Tapping sends [prompt] to the
/// chatbot as if the user had typed it.
class MSuggestionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const MSuggestionChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(MSizes.cardRadiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(MSizes.cardRadiusLg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MSizes.md,
            vertical: MSizes.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: MSizes.iconSm, color: scheme.primary),
              const SizedBox(width: MSizes.xs),
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: scheme.primary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
