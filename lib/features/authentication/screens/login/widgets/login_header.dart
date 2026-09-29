import 'package:flutter/material.dart';
import 'package:mockmaster/common/widgets/m_brand_header.dart';
import 'package:mockmaster/utils/constants/sizes.dart';
import 'package:mockmaster/utils/constants/text_strings.dart';

class MLoginHeader extends StatelessWidget {
  const MLoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Small blended icon + "MockMaster" name, replaces the old tall logo image
        const MBrandHeader(),
        const SizedBox(height: MSizes.spaceBtwSections),
        Text(
          MTexts.loginTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: MSizes.sm),
        Text(
          MTexts.loginSubTitle,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}