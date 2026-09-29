import 'package:flutter/material.dart';
import 'package:mockmaster/utils/constants/colors.dart';

/// Wrap any screen's body with this so the ombre gradient shows behind the
/// content. Use it together with `Scaffold(backgroundColor: Colors.transparent, ...)`.
///
/// Example:
/// ```dart
/// Scaffold(
///   backgroundColor: Colors.transparent,
///   body: MGradientBackground(
///     child: SafeArea(child: yourContent),
///   ),
/// )
/// ```
class MGradientBackground extends StatelessWidget {
  const MGradientBackground({
    super.key,
    required this.child,
    this.gradientOverride,
  });

  final Widget child;

  /// Optional: pass a custom gradient (e.g. once you send your theme colors)
  /// to override the default dark/light ombre.
  final Gradient? gradientOverride;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: gradientOverride ??
            (isDark
                ? MColors.darkOmbreBackground
                : MColors.lightOmbreBackground),
      ),
      child: child,
    );
  }
}