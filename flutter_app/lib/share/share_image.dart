import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../game/game_controller.dart';
import '../game/game_engine.dart';
import '../theme/dyfala_theme.dart';

class DyfalaShareImage {
  const DyfalaShareImage._();

  static Future<File> create(GameController controller) async {
    const width = 1080.0;
    const height = 1350.0;

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

    final title = TextPainter(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'DYFALA',
            style: TextStyle(
              color: DyfalaPalette.navy,
              fontSize: 108,
              fontWeight: FontWeight.w900,
              letterSpacing: -3,
            ),
          ),
          TextSpan(
            text: '!',
            style: TextStyle(
              color: DyfalaPalette.red,
              fontSize: 108,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    title.paint(canvas, Offset((width - title.width) / 2, 62));

    final underline = Paint()..color = DyfalaPalette.yellow;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(380, 177, 320, 14),
        const Radius.circular(99),
      ),
      underline,
    );

    _drawText(
      canvas,
      controller.practiceMode ? 'PRACTICE WORD' : 'DAILY WELSH WORD #${controller.puzzleNumber}',
      y: 220,
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
      y: 420,
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
      y: 486,
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
      y: 1095,
      width: width,
      size: 30,
      colour: DyfalaPalette.inkSoft,
      weight: FontWeight.w700,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(90, 1170, 900, 100),
        const Radius.circular(46),
      ),
      Paint()..color = DyfalaPalette.red,
    );

    _drawText(
      canvas,
      'Learning Welsh, one word at a time',
      y: 1201,
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
    const y = 336.0;
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
    const gap = 16.0;
    const rowGap = 16.0;
    final tile = math.min(
      140.0,
      (900.0 - math.max(0, tileCount - 1) * gap) / tileCount,
    );
    final gridWidth = tileCount * tile + (tileCount - 1) * gap;
    final left = (1080 - gridWidth) / 2;
    final rows = controller.guesses;
    final gridHeight = rows.length * tile + math.max(0, rows.length - 1) * rowGap;
    final top = 570 + math.max(0.0, (480 - gridHeight) / 2);

    for (var row = 0; row < rows.length; row++) {
      final guess = rows[row];
      for (var col = 0; col < guess.scores.length; col++) {
        final colour = switch (guess.scores[col]) {
          TileScore.correct => DyfalaPalette.greenLight,
          TileScore.present => DyfalaPalette.yellow,
          TileScore.absent => DyfalaPalette.absent,
        };

        final rect = Rect.fromLTWH(
          left + col * (tile + gap),
          top + row * (tile + rowGap),
          tile,
          tile,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(23)),
          Paint()..color = colour,
        );
      }
    }
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
