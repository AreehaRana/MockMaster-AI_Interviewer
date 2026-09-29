import 'package:flutter/material.dart';
import 'package:mockmaster/utils/constants/image_strings.dart';

/// Small, blended brand lockup used at the top of every auth screen.
class MBrandHeader extends StatelessWidget {
  const MBrandHeader({super.key, this.logoHeight = 32, this.spacing = 8});

  final double logoHeight;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Real app logo, swapped per theme, kept short instead of a full-height hero image
        Image(
          height: logoHeight,
          image: AssetImage(dark ? MImages.darkAppLogo : MImages.lightAppLogo),
        ),
        SizedBox(width: spacing),
        Text(
          'MockMaster',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}