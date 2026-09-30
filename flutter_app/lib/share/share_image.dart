import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../game/game_controller.dart';
import '../game/game_engine.dart';
import '../theme/dyfala_theme.dart';

class DyfalaShareImage {
  const DyfalaShareImage._();

  static const double _width = 1080;
  static const double _height = 1080;

  static Future<File> create(GameController controller) async {
    final approvedLogo =
        await _loadAssetImage('assets/approved/home-logo.png');

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawRect(
      const Rect.fromLTWH(0, 0, _width, _height),
      Paint()..color = DyfalaPalette.cream,
    );

    _drawDecor(canvas);

    _drawCroppedLogo(
      canvas,
      approvedLogo,
      const Rect.fromLTWH(210, 38, 660, 154),
    );

    _drawText(
      canvas,
      controller.practiceMode
          ? 'PRACTICE WORD'
          : 'DAILY WELSH WORD #${controller.puzzleNumber}',
      y: 225,
      size: 31,
      colour: DyfalaPalette.inkSoft,
      weight: FontWeight.w700,
      letterSpacing: 1.5,
    );

    _drawStars(canvas, controller.resultStars);

    _drawText(
      canvas,
      '${controller.resultStars} ${controller.resultStars == 1 ? 'STAR' : 'STARS'}',
      y: 385,
      size: 46,
      colour: DyfalaPalette.navy,
      weight: FontWeight.w700,
    );

    final attempts = controller.guesses.length;
    final result = controller.won
        ? 'Solved in $attempts/$maxGuesses'
        : 'Good try - $attempts/$maxGuesses';
    _drawText(
      canvas,
      result,
      y: 440,
      size: 35,
      colour: DyfalaPalette.greenDark,
      weight: FontWeight.w600,
    );

    _drawGrid(canvas, controller);

    _drawText(
      canvas,
      controller.hintsUsed == 0
          ? 'No hints needed'
          : '${controller.hintsUsed} ${controller.hintsUsed == 1 ? 'hint' : 'hints'} used',
      y: 910,
      size: 29,
      colour: DyfalaPalette.inkSoft,
      weight: FontWeight.w600,
    );

    _drawTextInRect(
      canvas,
      'Played on',
      const Rect.fromLTWH(250, 964, 300, 58),
      size: 38,
      colour: DyfalaPalette.inkSoft,
      weight: FontWeight.w600,
    );

    _drawCroppedLogo(
      canvas,
      approvedLogo,
      const Rect.fromLTWH(535, 948, 300, 78),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(_width.toInt(), _height.toInt());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) {
      throw StateError('Could not create share image.');
    }

    final file = File(
      '${Directory.systemTemp.path}/dyfala-share-${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    return file;
  }

  static void _drawDecor(Canvas canvas) {
    canvas.drawCircle(
      const Offset(-18, 30),
      185,
      Paint()..color = DyfalaPalette.red.withOpacity(.10),
    );
    canvas.drawCircle(
      const Offset(1105, 35),
      180,
      Paint()..color = DyfalaPalette.yellow.withOpacity(.12),
    );
    canvas.drawCircle(
      const Offset(-5, 1115),
      185,
      Paint()..color = DyfalaPalette.green.withOpacity(.10),
    );
    canvas.drawCircle(
      const Offset(1100, 1110),
      170,
      Paint()..color = DyfalaPalette.red.withOpacity(.09),
    );

    final yellowDash = Paint()
      ..color = DyfalaPalette.yellow.withOpacity(.85)
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(120, 178), const Offset(150, 204), yellowDash);
    canvas.drawLine(const Offset(158, 148), const Offset(178, 176), yellowDash);

    final greenDash = Paint()
      ..color = DyfalaPalette.greenLight.withOpacity(.26)
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(978, 236), const Offset(999, 208), greenDash);
    canvas.drawLine(const Offset(1008, 272), const Offset(1038, 250), greenDash);

    canvas.drawLine(const Offset(972, 892), const Offset(994, 918), yellowDash);
    canvas.drawLine(const Offset(1004, 874), const Offset(1027, 901), yellowDash);
  }

  static void _drawStars(Canvas canvas, int stars) {
    const y = 330.0;
    const spacing = 142.0;
    final start = _width / 2 - spacing;

    for (var index = 0; index < 3; index++) {
      final center = Offset(start + spacing * index, y);
      final path = _starPath(center, 52, 23);
      final earned = index < stars;
      if (earned) {
        canvas.drawPath(path, Paint()..color = DyfalaPalette.yellow);
      } else {
        canvas.drawPath(
          path,
          Paint()
            ..color = DyfalaPalette.absent
            ..style = PaintingStyle.stroke
            ..strokeWidth = 7,
        );
      }
    }
  }

  static Path _starPath(Offset center, double outer, double inner) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final radius = i.isEven ? outer : inner;
      final angle = -math.pi / 2 + i * math.pi / 5;
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path..close();
  }

  static void _drawGrid(Canvas canvas, GameController controller) {
    final tileCount = controller.answerTokens.length;
    final rows = controller.guesses;
    if (tileCount == 0 || rows.isEmpty) return;

    const maxWidth = 520.0;
    const maxHeight = 380.0;
    const gap = 10.0;

    final widthLimited =
        (maxWidth - math.max(0, tileCount - 1) * gap) / tileCount;
    final heightLimited =
        (maxHeight - math.max(0, rows.length - 1) * gap) / rows.length;
    final tileSize = math.min(68.0, math.min(widthLimited, heightLimited));

    final gridWidth =
        tileCount * tileSize + math.max(0, tileCount - 1) * gap;
    final gridHeight =
        rows.length * tileSize + math.max(0, rows.length - 1) * gap;
    final left = (_width - gridWidth) / 2;
    final top = 510 + (maxHeight - gridHeight) / 2;

    for (var row = 0; row < rows.length; row++) {
      final guess = rows[row];
      for (var col = 0; col < guess.scores.length; col++) {
        final colour = switch (guess.scores[col]) {
          TileScore.correct => DyfalaPalette.greenLight,
          TileScore.present => DyfalaPalette.yellow,
          TileScore.absent => DyfalaPalette.absent,
        };

        final rect = Rect.fromLTWH(
          left + col * (tileSize + gap),
          top + row * (tileSize + gap),
          tileSize,
          tileSize,
        );

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            rect,
            Radius.circular(math.min(12, tileSize * .18)),
          ),
          Paint()..color = colour,
        );
      }
    }
  }

  static Future<ui.Image> _loadAssetImage(String path) async {
    final data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  static void _drawCroppedLogo(
    Canvas canvas,
    ui.Image image,
    Rect destination,
  ) {
    final sourceWidth = image.width * .92;
    final source = Rect.fromLTWH(
      0,
      0,
      sourceWidth,
      image.height.toDouble(),
    );
    final fitted = _containRect(
      Size(sourceWidth, image.height.toDouble()),
      destination,
    );
    canvas.drawImageRect(
      image,
      source,
      fitted,
      Paint()..filterQuality = FilterQuality.high,
    );
  }

  static Rect _containRect(Size source, Rect destination) {
    final scale = math.min(
      destination.width / source.width,
      destination.height / source.height,
    );
    final width = source.width * scale;
    final height = source.height * scale;
    return Rect.fromLTWH(
      destination.left + (destination.width - width) / 2,
      destination.top + (destination.height - height) / 2,
      width,
      height,
    );
  }

  static void _drawTextInRect(
    Canvas canvas,
    String text,
    Rect rect, {
    required double size,
    required Color colour,
    required FontWeight weight,
    double letterSpacing = 0,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.fredoka(
          color: colour,
          fontSize: size,
          fontWeight: weight,
          letterSpacing: letterSpacing,
          height: 1,
        ),
      ),
      maxLines: 1,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: rect.width);

    painter.paint(
      canvas,
      Offset(
        rect.left + (rect.width - painter.width) / 2,
        rect.top + (rect.height - painter.height) / 2,
      ),
    );
  }

  static void _drawText(
    Canvas canvas,
    String text, {
    required double y,
    required double size,
    required Color colour,
    required FontWeight weight,
    double letterSpacing = 0,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.fredoka(
          color: colour,
          fontSize: size,
          fontWeight: weight,
          letterSpacing: letterSpacing,
          height: 1.05,
        ),
      ),
      maxLines: 2,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: _width - 100);

    painter.paint(
      canvas,
      Offset((_width - painter.width) / 2, y),
    );
  }
}
