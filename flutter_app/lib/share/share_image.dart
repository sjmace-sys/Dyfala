import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/game_controller.dart';
import '../game/game_engine.dart';
import '../theme/dyfala_theme.dart';

class DyfalaShareImage {
  const DyfalaShareImage._();

  static Future<File> create(GameController controller) async {
    const width = 1080.0;
    const height = 1350.0;

    final approvedLogo = await _loadAssetImage('assets/brand/dyfala-logo.png');

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final background = Paint()..color = DyfalaPalette.cream;
    canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), background);

    _drawDecor(canvas, width, height);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(34, 34, 1012, 1282),
        const Radius.circular(58),
      ),
      Paint()..color = const Color(0xFFFFFDF8).withOpacity(.94),
    );

    final logoRect = _containRect(
      Size(approvedLogo.width.toDouble(), approvedLogo.height.toDouble()),
      const Rect.fromLTWH(220, 64, 640, 150),
    );
    canvas.drawImageRect(
      approvedLogo,
      Rect.fromLTWH(
        0,
        0,
        approvedLogo.width.toDouble(),
        approvedLogo.height.toDouble(),
      ),
      logoRect,
      Paint()..filterQuality = FilterQuality.high,
    );

    _drawText(
      canvas,
      controller.practiceMode ? 'PRACTICE WORD' : 'DAILY WELSH WORD #${controller.puzzleNumber}',
      y: 230,
      width: width,
      size: 27,
      colour: DyfalaPalette.inkSoft,
      weight: FontWeight.w800,
      letterSpacing: 2.0,
    );

    _drawStars(canvas, controller.resultStars, width);

    _drawText(
      canvas,
      '${controller.resultStars} ${controller.resultStars == 1 ? 'STAR' : 'STARS'}',
      y: 408,
      width: width,
      size: 48,
      colour: DyfalaPalette.navy,
      weight: FontWeight.w900,
    );

    final result = controller.won
        ? 'Solved in ${controller.guesses.length} / $maxGuesses'
        : 'Good try · X / $maxGuesses';
    _drawText(
      canvas,
      result,
      y: 468,
      width: width,
      size: 34,
      colour: DyfalaPalette.greenDark,
      weight: FontWeight.w800,
    );

    _drawGrid(canvas, controller);

    _drawText(
      canvas,
      controller.hintsUsed == 0
          ? 'No hints needed'
          : '${controller.hintsUsed} ${controller.hintsUsed == 1 ? 'hint' : 'hints'} used',
      y: 955,
      width: width,
      size: 29,
      colour: DyfalaPalette.inkSoft,
      weight: FontWeight.w700,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(130, 1015, 820, 105),
        const Radius.circular(44),
      ),
      Paint()..color = const Color(0xFFFFF7E5),
    );

    _drawTextInRect(
      canvas,
      'PLAYED ON',
      const Rect.fromLTWH(170, 1047, 250, 42),
      size: 27,
      colour: DyfalaPalette.inkSoft,
      weight: FontWeight.w900,
      letterSpacing: 1.4,
    );

    final playedLogoRect = _containRect(
      Size(approvedLogo.width.toDouble(), approvedLogo.height.toDouble()),
      const Rect.fromLTWH(455, 1031, 430, 72),
    );
    canvas.drawImageRect(
      approvedLogo,
      Rect.fromLTWH(
        0,
        0,
        approvedLogo.width.toDouble(),
        approvedLogo.height.toDouble(),
      ),
      playedLogoRect,
      Paint()..filterQuality = FilterQuality.high,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(90, 1160, 900, 105),
        const Radius.circular(46),
      ),
      Paint()..color = DyfalaPalette.red,
    );

    _drawText(
      canvas,
      'Learning Welsh, one word at a time',
      y: 1194,
      width: width,
      size: 31,
      colour: Colors.white,
      weight: FontWeight.w800,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
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

  static void _drawDecor(Canvas canvas, double width, double height) {
    canvas.drawCircle(
      const Offset(86, 94),
      118,
      Paint()..color = DyfalaPalette.red.withOpacity(.10),
    );
    canvas.drawCircle(
      Offset(width - 40, 325),
      145,
      Paint()..color = DyfalaPalette.yellow.withOpacity(.12),
    );
    canvas.drawCircle(
      Offset(90, height - 70),
      165,
      Paint()..color = DyfalaPalette.green.withOpacity(.10),
    );
  }

  static void _drawStars(Canvas canvas, int stars, double width) {
    const y = 326.0;
    const spacing = 210.0;
    final start = width / 2 - spacing;

    for (var index = 0; index < 3; index++) {
      final center = Offset(start + spacing * index, y);
      final path = _starPath(center, 82, 37);
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

    const colGap = 14.0;
    const rowGap = 12.0;
    const maxGridWidth = 860.0;
    const maxGridHeight = 390.0;

    final byWidth =
        (maxGridWidth - math.max(0, tileCount - 1) * colGap) / tileCount;
    final byHeight =
        (maxGridHeight - math.max(0, rows.length - 1) * rowGap) / rows.length;
    final tile = math.min(128.0, math.min(byWidth, byHeight));

    final gridWidth = tileCount * tile + (tileCount - 1) * colGap;
    final gridHeight = rows.length * tile + (rows.length - 1) * rowGap;
    final left = (1080 - gridWidth) / 2;
    final top = 540 + (maxGridHeight - gridHeight) / 2;

    for (var row = 0; row < rows.length; row++) {
      final guess = rows[row];
      for (var col = 0; col < guess.scores.length; col++) {
        final colour = switch (guess.scores[col]) {
          TileScore.correct => DyfalaPalette.greenLight,
          TileScore.present => DyfalaPalette.yellow,
          TileScore.absent => DyfalaPalette.absent,
        };

        final rect = Rect.fromLTWH(
          left + col * (tile + colGap),
          top + row * (tile + rowGap),
          tile,
          tile,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            rect,
            Radius.circular(math.min(22.0, tile * .18)),
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
        style: TextStyle(
          color: colour,
          fontSize: size,
          fontWeight: weight,
          letterSpacing: letterSpacing,
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
    required double width,
    required double size,
    required Color colour,
    required FontWeight weight,
    double letterSpacing = 0,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: colour,
          fontSize: size,
          fontWeight: weight,
          letterSpacing: letterSpacing,
        ),
      ),
      maxLines: 2,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width - 88);

    painter.paint(canvas, Offset((width - painter.width) / 2, y));
  }
}
