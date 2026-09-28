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

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(24, 24, 1032, 1032),
        const Radius.circular(50),
      ),
      Paint()..color = const Color(0xFFFFFDF8).withOpacity(.97),
    );

    _drawCroppedLogo(
      canvas,
      approvedLogo,
      const Rect.fromLTWH(185, 42, 710, 152),
    );

    _drawText(
      canvas,
      controller.practiceMode
          ? 'PRACTICE WORD'
          : 'DAILY WELSH WORD #${controller.puzzleNumber}',
      y: 190,
      size: 29,
      colour: DyfalaPalette.inkSoft,
      weight: FontWeight.w700,
      letterSpacing: 1.5,
    );

    _drawStars(canvas, controller.resultStars);

    _drawText(
      canvas,
      '${controller.resultStars} ${controller.resultStars == 1 ? 'STAR' : 'STARS'}',
      y: 355,
      size: 47,
      colour: DyfalaPalette.navy,
      weight: FontWeight.w700,
    );

    final result = controller.won
        ? 'Solved in ${controller.guesses.length} / $maxGuesses'
        : 'Good try · X / $maxGuesses';
    _drawText(
      canvas,
      result,
      y: 410,
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
      y: 790,
      size: 30,
      colour: DyfalaPalette.inkSoft,
      weight: FontWeight.w600,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(105, 842, 870, 100),
        const Radius.circular(44),
      ),
      Paint()..color = const Color(0xFFFFF3D6),
    );

    _drawTextInRect(
      canvas,
      'PLAYED ON',
      const Rect.fromLTWH(150, 870, 270, 44),
      size: 31,
      colour: DyfalaPalette.inkSoft,
      weight: FontWeight.w700,
      letterSpacing: .8,
    );

    _drawCroppedLogo(
      canvas,
      approvedLogo,
      const Rect.fromLTWH(445, 858, 430, 68),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(80, 968, 920, 76),
        const Radius.circular(38),
      ),
      Paint()..color = DyfalaPalette.red,
    );

    _drawText(
      canvas,
      'Learning Welsh, one word at a time',
      y: 986,
      size: 29,
      colour: Colors.white,
      weight: FontWeight.w600,
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
      const Offset(70, 80),
      105,
      Paint()..color = DyfalaPalette.red.withOpacity(.09),
    );
    canvas.drawCircle(
      const Offset(1040, 255),
      125,
      Paint()..color = DyfalaPalette.yellow.withOpacity(.11),
    );
    canvas.drawCircle(
      const Offset(60, 1015),
      130,
      Paint()..color = DyfalaPalette.green.withOpacity(.09),
    );
  }

  static void _drawStars(Canvas canvas, int stars) {
    const y = 286.0;
    const spacing = 205.0;
    final start = _width / 2 - spacing;

    for (var index = 0; index < 3; index++) {
      final center = Offset(start + spacing * index, y);
      final path = _starPath(center, 72, 32);
      final earned = index < stars;
      if (earned) {
        canvas.drawPath(path, Paint()..color = DyfalaPalette.yellow);
      } else {
        canvas.drawPath(
          path,
          Paint()
            ..color = DyfalaPalette.absent
            ..style = PaintingStyle.stroke
            ..strokeWidth = 8,
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

    const maxWidth = 780.0;
    const maxHeight = 300.0;
    const colGap = 14.0;
    const rowGap = 10.0;

    final tileWidth = math.min(
      122.0,
      (maxWidth - math.max(0, tileCount - 1) * colGap) / tileCount,
    );
    final tileHeight = math.min(
      62.0,
      (maxHeight - math.max(0, rows.length - 1) * rowGap) / rows.length,
    );

    final gridWidth =
        tileCount * tileWidth + math.max(0, tileCount - 1) * colGap;
    final gridHeight =
        rows.length * tileHeight + math.max(0, rows.length - 1) * rowGap;
    final left = (_width - gridWidth) / 2;
    final top = 465 + (maxHeight - gridHeight) / 2;

    for (var row = 0; row < rows.length; row++) {
      final guess = rows[row];
      for (var col = 0; col < guess.scores.length; col++) {
        final colour = switch (guess.scores[col]) {
          TileScore.correct => DyfalaPalette.greenLight,
          TileScore.present => DyfalaPalette.yellow,
          TileScore.absent => DyfalaPalette.absent,
        };

        final rect = Rect.fromLTWH(
          left + col * (tileWidth + colGap),
          top + row * (tileHeight + rowGap),
          tileWidth,
          tileHeight,
        );

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            rect,
            Radius.circular(math.min(18, tileHeight * .28)),
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
