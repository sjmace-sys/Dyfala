import 'package:flutter/material.dart';

import '../theme/dyfala_theme.dart';

class ApprovedDyfalaLogo extends StatelessWidget {
  const ApprovedDyfalaLogo({
    super.key,
    this.height = 58,
    this.maxWidth,
  });

  final double height;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final underlineWidth = height * 1.72;

    Widget logo = SizedBox(
      height: height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Image.asset(
              'assets/brand/dyfala-logo.png',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: underlineWidth,
            height: height * .085,
            decoration: BoxDecoration(
              color: DyfalaPalette.yellow,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );

    if (maxWidth != null) {
      logo = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth!),
        child: logo,
      );
    }

    return Semantics(label: 'Dyfala!', child: logo);
  }
}
