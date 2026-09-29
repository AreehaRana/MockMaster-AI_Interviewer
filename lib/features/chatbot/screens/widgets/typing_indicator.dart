import 'package:flutter/material.dart';
import 'package:mockmaster/utils/constants/sizes.dart';
import 'package:mockmaster/utils/helpers/helper_function.dart';

/// Three-dot "typing..." bubble shown on the AI side while a reply is
/// being generated. Styled like an AI [ChatBubble] so it reads as part
/// of the same conversation.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = MHelperFunctions.isDarkMode(context);
    final scheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: MSizes.xs),
        padding: const EdgeInsets.symmetric(
          horizontal: MSizes.md,
          vertical: MSizes.sm + 2,
        ),
        decoration: BoxDecoration(
          color: dark ? scheme.surfaceContainerHigh : scheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(MSizes.cardRadiusMd),
            topRight: Radius.circular(MSizes.cardRadiusMd),
            bottomRight: Radius.circular(MSizes.cardRadiusMd),
            bottomLeft: Radius.circular(MSizes.xs),
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final t = (_controller.value - (i * 0.2)) % 1.0;
                final scale = 0.6 + (t < 0.5 ? t : 1 - t);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Transform.scale(
                    scale: scale.clamp(0.6, 1.0),
                    child: CircleAvatar(
                      radius: 4,
                      backgroundColor: scheme.primary.withValues(alpha: 0.7),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
