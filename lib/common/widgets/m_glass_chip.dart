import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mockmaster/utils/constants/colors.dart';

/// Small frosted glass pill/circle — used for buttons that float over images.
class MGlassChip extends StatelessWidget {
  const MGlassChip({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.borderRadius = 100,
    this.blurSigma = 12,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: isDark ? MColors.glassFillDark : MColors.glassFillLight,
            border: Border.all(
              color: isDark ? MColors.glassBorderDark : MColors.glassBorderLight,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}