import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mockmaster/common/widgets/app_drawer.dart';

/// Opens the app drawer as a custom overlay instead of Scaffold's built-in
/// drawer, so the previous screen visibly BLURS behind it (native
/// Scaffold(drawer:) only dims, it can't blur). Tapping the blurred area
/// closes the drawer, same as the X button inside MAppDrawer.
///
/// Call this from wherever the hamburger/menu icon is, e.g.:
///   IconButton(
///     icon: const Icon(Icons.menu),
///     onPressed: () => showBlurDrawer(context),
///   )
Future<void> showBlurDrawer(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Menu',
    barrierColor: Colors.transparent, // we paint our own blurred barrier below
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final value = Curves.easeOutCubic.transform(animation.value);
          return Stack(
            children: [
              // Blurred + dimmed backdrop over the screen behind the drawer.
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 6 * value,
                      sigmaY: 6 * value,
                    ),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.35 * value),
                    ),
                  ),
                ),
              ),
              // The drawer panel itself, sliding in from the left.
              Align(
                alignment: Alignment.centerLeft,
                child: FractionalTranslation(
                  translation: Offset(-1 + value, 0),
                  child: const MAppDrawer(),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}