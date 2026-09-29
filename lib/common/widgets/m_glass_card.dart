import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mockmaster/utils/constants/colors.dart';

/// Frosted-glass card used for auth screens (login, sign up, OTP, etc).
/// Unlike a full-screen form, this constrains its own width/height so the
/// ombre background stays visible around it — exactly like the PrepWise
/// reference (a centered card floating over the background, not edge to edge).
///
/// Usage:
/// ```dart
/// Scaffold(
///   backgroundColor: Colors.transparent,
///   body: MGradientBackground(
///     child: SafeArea(
///       child: Padding(
///         padding: const EdgeInsets.symmetric(horizontal: 24),
///         child: MGlassCard(
///           child: Column(
///             mainAxisSize: MainAxisSize.min,
///             children: [...],
///           ),
///         ),
///       ),
///     ),
///   ),
/// )
/// ```
class MGlassCard extends StatefulWidget {
  const MGlassCard({
    super.key,
    required this.child,
    this.maxWidth = 420,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
    this.borderRadius = 28,
    this.blurSigma = 18,
    this.animate = true,
  });

  final Widget child;

  /// Card never grows wider than this — keeps it "card-like" on tablets/web
  /// instead of stretching full width.
  final double maxWidth;

  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blurSigma;

  /// Set false to skip the entrance fade/scale animation.
  final bool animate;

  @override
  State<MGlassCard> createState() => _MGlassCardState();
}

class _MGlassCardState extends State<MGlassCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  late final Animation<double> _scale = Tween<double>(begin: 0.94, end: 1.0)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final card = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.maxWidth),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: widget.blurSigma,
              sigmaY: widget.blurSigma,
            ),
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                color: isDark ? MColors.glassFillDark : MColors.glassFillLight,
                border: Border.all(
                  color:
                      isDark ? MColors.glassBorderDark : MColors.glassBorderLight,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        isDark ? MColors.glassShadowDark : MColors.glassShadowLight,
                    blurRadius: 30,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );

    if (!widget.animate) return card;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Opacity(
        opacity: _fade.value,
        child: Transform.scale(scale: _scale.value, child: card),
      ),
    );
  }
}