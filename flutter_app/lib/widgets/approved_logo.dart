import 'package:flutter/material.dart';

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
    final logo = FittedBox(
      fit: BoxFit.contain,
      child: ClipRect(
        child: Align(
          alignment: Alignment.centerLeft,
          widthFactor: .92,
          child: Image.asset(
            'assets/approved/home-logo.png',
            width: 625,
            height: 205,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );

    return Semantics(
      label: 'Dyfala!',
      child: SizedBox(
        height: height,
        width: maxWidth,
        child: logo,
      ),
    );
  }
}
