import 'package:flutter/material.dart';
import 'package:mockmaster/utils/constants/sizes.dart';
import 'package:mockmaster/utils/helpers/helper_function.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.subTitle,
  });

  final String image;
  final String title;
  final String subTitle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Image height is now a fraction of THIS page's actual available
        // height (constraints.maxHeight), not the full screen height --
        // so it never overflows when the app bar, status bar, or a
        // shorter/landscape screen leaves less vertical room than
        // expected. Clamped so it doesn't get comically small or huge.
        final imageHeight = (constraints.maxHeight * 0.45).clamp(140.0, 420.0);
        final imageWidth = (constraints.maxWidth * 0.8).clamp(160.0, 500.0);

        return SingleChildScrollView(
          // Scrolls instead of overflowing if title+subtitle text is long
          // or the screen is short (e.g. landscape phones, small tablets).
          padding: const EdgeInsets.all(MSizes.defaultSpace),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  width: imageWidth,
                  height: imageHeight,
                  fit: BoxFit.contain,
                  image: AssetImage(image),
                ),
                const SizedBox(height: MSizes.spaceBtwSections),

                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: MSizes.spaceBtwItems),

                Text(
                  subTitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}