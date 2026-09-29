import 'package:flutter/material.dart';
import 'package:mockmaster/utils/constants/image_strings.dart';
import 'package:mockmaster/utils/constants/sizes.dart';
import 'package:mockmaster/utils/helpers/helper_function.dart';

/// Dashboard top header -- just the theme-aware app logo.
///
/// The personalized "Welcome, {name}" greeting lives inside [MHeroBanner]
/// instead (as requested), so it isn't duplicated here.
class MHomeHeader extends StatelessWidget {
  const MHomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = MHelperFunctions.isDarkMode(context);

    return Image(
      height: 32,
      image: AssetImage(dark ? MImages.darkAppLogo : MImages.lightAppLogo),
    );
  }
}
