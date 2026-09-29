import 'package:flutter/material.dart';

import 'package:mockmaster/utils/constants/colors.dart';
import 'package:mockmaster/utils/constants/sizes.dart';

class MAnimationLoaderWidget
    extends
        StatelessWidget {
  const MAnimationLoaderWidget({
    super.key,
    required this.text,
    required this.animation,
    this.showAction =
        false,
    this.actionText,
    this.onActionPressed,
  });

  final String
  text;
  final String
  animation;
  final bool
  showAction;
  final String?
  actionText;
  final VoidCallback?
  onActionPressed;

  @override
  Widget
  build(
    BuildContext
    context,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            animation,
            width:
                MediaQuery.of(
                  context,
                ).size.width *
                0.5,
            height: 150,
            fit: BoxFit.contain,
          ),

          const SizedBox(
            height: MSizes.defaultSpace,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: MSizes.defaultSpace,
            ),
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(
            height: MSizes.defaultSpace,
          ),

          if (showAction)
            SizedBox(
              width: 250,
              child: OutlinedButton(
                onPressed: onActionPressed,
                style: OutlinedButton.styleFrom(
                  backgroundColor: MColors.dark,
                ),
                child: Text(
                  actionText ??
                      '',
                  style:
                      Theme.of(
                        context,
                      ).textTheme.bodyMedium!.apply(
                        color: MColors.light,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
