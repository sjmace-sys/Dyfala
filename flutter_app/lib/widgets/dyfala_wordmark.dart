import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/dyfala_theme.dart';

class DyfalaWordmark extends StatelessWidget {
  const DyfalaWordmark({
    super.key,
    this.fontSize = 48,
    this.color = DyfalaPalette.navy,
    this.exclamationColor,
    this.useConceptLogo = true,
  });

  final double fontSize;
  final Color color;
  final Color? exclamationColor;
  final bool useConceptLogo;

  @override
  Widget build(BuildContext context) {
    final markColor = exclamationColor ?? DyfalaPalette.red;
    final textStyle = GoogleFonts.lilitaOne(
      fontSize: fontSize,
      height: .92,
      fontWeight: FontWeight.w400,
      letterSpacing: -1.6,
      color: color,
    );

    final rayWidth = fontSize * .16;
    final rayHeight = fontSize * .38;

    return Semantics(
      label: 'Dyfala!',
      child: SizedBox(
        height: fontSize * 1.16,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: fontSize * .36,
                height: fontSize * .70,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: fontSize * .20,
                      child: _Ray(width: rayWidth, height: rayHeight, angle: -1.22, color: markColor),
                    ),
                    Positioned(
                      left: fontSize * .04,
                      top: fontSize * .02,
                      child: _Ray(width: rayWidth, height: rayHeight, angle: -.52, color: markColor),
                    ),
                    Positioned(
                      left: fontSize * .14,
                      top: fontSize * .40,
                      child: _Ray(width: rayWidth, height: rayHeight, angle: .10, color: markColor),
                    ),
                  ],
                ),
              ),
              Text('DYFALA', style: textStyle),
              const SizedBox(width: 2),
              Text(
                '!',
                style: textStyle.copyWith(color: markColor, fontSize: fontSize * 1.03),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Ray extends StatelessWidget {
  const _Ray({required this.width, required this.height, required this.angle, required this.color});

  final double width;
  final double height;
  final double angle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(width),
        ),
      ),
    );
  }
}
