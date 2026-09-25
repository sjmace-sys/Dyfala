import 'package:flutter/material.dart';

import '../theme/dyfala_theme.dart';

class WelshLandscape extends StatelessWidget {
  const WelshLandscape({
    super.key,
    this.height = 170,
    this.showCastle = true,
    this.compact = false,
  });

  final double height;
  final bool showCastle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(
        painter: _LandscapePainter(
          showCastle: showCastle,
          compact: compact,
        ),
      ),
    );
  }
}

class _LandscapePainter extends CustomPainter {
  const _LandscapePainter({required this.showCastle, required this.compact});

  final bool showCastle;
  final bool compact;

  @override
  void paint(Canvas canvas, Size size) {
    final red = Paint()..color = DyfalaPalette.red;
    final green = Paint()..color = DyfalaPalette.greenLight;
    final darkGreen = Paint()..color = DyfalaPalette.greenDark;
    final yellow = Paint()..color = DyfalaPalette.yellow;
    final river = Paint()..color = const Color(0xFFE9E2D5);
    final castlePaint = Paint()..color = DyfalaPalette.redDark;

    final sunRadius = compact ? 20.0 : 27.0;
    canvas.drawCircle(
      Offset(size.width * .77, size.height * .23),
      sunRadius,
      yellow,
    );

    final redHill = Path()
      ..moveTo(0, size.height * .54)
      ..quadraticBezierTo(
        size.width * .20,
        size.height * .24,
        size.width * .47,
        size.height * .58,
      )
      ..quadraticBezierTo(
        size.width * .65,
        size.height * .78,
        size.width,
        size.height * .55,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(redHill, red);

    final backHill = Path()
      ..moveTo(size.width * .25, size.height)
      ..quadraticBezierTo(
        size.width * .62,
        size.height * .43,
        size.width,
        size.height * .62,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(backHill, green);

    final frontHill = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(
        size.width * .30,
        size.height * .70,
        size.width * .56,
        size.height * .88,
      )
      ..quadraticBezierTo(
        size.width * .75,
        size.height * .98,
        size.width,
        size.height * .72,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(frontHill, darkGreen);

    final riverPath = Path()
      ..moveTo(size.width * .54, size.height)
      ..quadraticBezierTo(
        size.width * .58,
        size.height * .86,
        size.width * .72,
        size.height * .76,
      )
      ..quadraticBezierTo(
        size.width * .80,
        size.height * .70,
        size.width * .78,
        size.height * .64,
      )
      ..quadraticBezierTo(
        size.width * .71,
        size.height * .77,
        size.width * .67,
        size.height,
      )
      ..close();
    canvas.drawPath(riverPath, river);

    if (showCastle) {
      final scale = compact ? .70 : 1.0;
      final baseW = 52.0 * scale;
      final baseH = 34.0 * scale;
      final left = size.width * .20;
      final top = size.height * .54;
      canvas.drawRect(Rect.fromLTWH(left, top, baseW, baseH), castlePaint);
      canvas.drawRect(
        Rect.fromLTWH(left - 6 * scale, top - 15 * scale, 14 * scale, 49 * scale),
        castlePaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(left + baseW - 8 * scale, top - 20 * scale, 14 * scale, 54 * scale),
        castlePaint,
      );
      final door = Paint()..color = DyfalaPalette.cream;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            left + baseW * .40,
            top + baseH * .48,
            baseW * .20,
            baseH * .52,
          ),
          Radius.circular(7 * scale),
        ),
        door,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LandscapePainter oldDelegate) {
    return oldDelegate.showCastle != showCastle || oldDelegate.compact != compact;
  }
}
