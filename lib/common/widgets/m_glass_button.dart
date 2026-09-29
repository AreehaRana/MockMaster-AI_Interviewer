import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mockmaster/utils/constants/colors.dart';

/// Pill-shaped frosted-glass button that matches [MGlassPanel] /
/// [MGlassCard] glassmorphism language.
///
/// Use [MGlassButton.filled] for primary CTAs and [MGlassButton.outlined]
/// for secondary actions — mirroring ElevatedButton / OutlinedButton.
class MGlassButton extends StatefulWidget {
  /// Primary filled glass button (like ElevatedButton).
  const MGlassButton.filled({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  }) : outlined = false;

  /// Secondary outlined glass button (like OutlinedButton).
  const MGlassButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  }) : outlined = true;

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool outlined;

  @override
  State<MGlassButton> createState() => _MGlassButtonState();
}

class _MGlassButtonState extends State<MGlassButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  bool _pressed = false;

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: widget.outlined
                        ? null
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              scheme.primary
                                  .withValues(alpha: isDark ? 0.45 : 0.30),
                              scheme.primary
                                  .withValues(alpha: isDark ? 0.22 : 0.14),
                            ],
                          ),
                    color: widget.outlined
                        ? (isDark
                            ? MColors.glassFillDark
                            : MColors.glassFillLight)
                        : null,
                    border: Border.all(
                      color: widget.outlined
                          ? (isDark
                              ? MColors.glassBorderDark
                              : MColors.glassBorderLight)
                          : scheme.primary.withValues(alpha: 0.55),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.outlined
                            ? (isDark
                                ? MColors.glassShadowDark
                                : MColors.glassShadowLight)
                            : scheme.primary.withValues(alpha: 0.28),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Shimmer sweep (only for filled variant)
                      if (!widget.outlined)
                        AnimatedBuilder(
                          animation: _shimmerController,
                          builder: (context, _) {
                            final progress = _shimmerController.value;
                            final travel = width + 120;
                            final left = -60 + progress * travel;

                            return Positioned(
                              left: left,
                              top: -20,
                              bottom: -20,
                              width: 50,
                              child: Transform.rotate(
                                angle: 0.5,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Colors.white.withValues(alpha: 0),
                                        Colors.white.withValues(
                                            alpha: isDark ? 0.22 : 0.35),
                                        Colors.white.withValues(alpha: 0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                      // Label + icon
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                color:
                                    isDark ? Colors.white : scheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              widget.label,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: isDark
                                        ? Colors.white
                                        : scheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}