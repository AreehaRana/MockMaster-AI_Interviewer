import 'package:flutter/material.dart';
import 'package:mockmaster/data/repositories/repositories.authentication/authentication_repository.dart';
import 'package:mockmaster/utils/constants/colors.dart';
import 'package:mockmaster/utils/constants/image_strings.dart';
import 'package:mockmaster/utils/constants/sizes.dart';
import 'package:mockmaster/utils/popups/full_screen_loader.dart';
import 'package:mockmaster/utils/popups/loaders.dart';

class MSocialButtons extends StatelessWidget {
  const MSocialButtons({super.key});

  /// Runs the real Google sign-in flow: shows a loader, calls Firebase
  /// via AuthenticationRepository, then routes the same way every other
  /// sign-in method does.
  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      MFullScreenLoader.openLoadingDialog(
        'Signing you in with Google...',
        MImages.animationLoader,
      );

      final credential =
          await AuthenticationRepository.instance.signInWithGoogle();

      MFullScreenLoader.stopLoading();

      if (credential == null) {
        // User closed the Google account picker -- nothing went wrong,
        // just nothing to do.
        return;
      }

      // Google accounts are pre-verified by Google, so this lands
      // straight on HomeScreen via the same routing every other
      // sign-in method uses.
      await AuthenticationRepository.instance.screenRedirect();
    } catch (e) {
      MFullScreenLoader.stopLoading();
      MLoaders.errorSnackBar(
        title: 'Google Sign-In Failed',
        message: e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Facebook removed — Google only
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: MColors.grey),
            borderRadius: BorderRadius.circular(100),
          ),
          child: IconButton(
            onPressed: () => _handleGoogleSignIn(context),
            icon: const Image(
              width: MSizes.iconMd,
              height: MSizes.iconMd,
              image: AssetImage(MImages.google),
            ),
          ),
        ),
      ],
    ); // Row
  }
}