import 'package:flutter/material.dart';
import 'package:mockmaster/common/widgets/m_glass_chip.dart';
import 'package:mockmaster/utils/constants/sizes.dart';

class MTechnologyBadge extends StatelessWidget {
  final String label;

  const MTechnologyBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    // Frosted glass chip instead of a flat surface-colored container
    return MGlassChip(
      padding: const EdgeInsets.symmetric(
        horizontal: MSizes.sm,
        vertical: MSizes.xs / 2,
      ),
      borderRadius: MSizes.borderRadiusSm,
      blurSigma: 6,
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}