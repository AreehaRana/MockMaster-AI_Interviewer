import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mockmaster/utils/constants/colors.dart';

/// Frosted glass panel that fills its parent's width — unlike [MGlassCard]
/// (which centers and caps its own width for auth screens), this is for
/// content that needs to fill a banner or a grid tile.
class MGlassPanel extends StatefulWidget {
  const MGlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24,
    this.blurSigma = 16,
    this.animate = true,
    this.borderColor,
    this.borderWidth = 1.2,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blurSigma;

  /// Set false to skip the entrance fade/scale animation.
  final bool animate;

  /// Overrides the default glass border — e.g. primary color when "active",
  /// or error color when a required item is missing.
  final Color? borderColor;
  final double borderWidth;

  @override
  State<MGlassPanel> createState() => _MGlassPanelState();
}

class _MGlassPanelState extends State<MGlassPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  late final Animation<double> _scale = Tween<double>(begin: 0.96, end: 1.0)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final panel = ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: widget.blurSigma,
          sigmaY: widget.blurSigma,
        ),
        child: Container(
          width: double.infinity,
          padding: widget.padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            color: isDark ? MColors.glassFillDark : MColors.glassFillLight,
            border: Border.all(
              color: widget.borderColor ??
                  (isDark ? MColors.glassBorderDark : MColors.glassBorderLight),
              width: widget.borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    isDark ? MColors.glassShadowDark : MColors.glassShadowLight,
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );

    if (!widget.animate) return panel;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Opacity(
        opacity: _fade.value,
        child: Transform.scale(scale: _scale.value, child: panel),
      ),
    );
  }
}