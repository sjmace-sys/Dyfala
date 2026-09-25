import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/game_engine.dart';
import '../theme/dyfala_theme.dart';

class TileBoard extends StatelessWidget {
  const TileBoard({
    super.key,
    required this.answerLength,
    required this.guesses,
    required this.currentGuess,
  });

  final int answerLength;
  final List<EvaluatedGuess> guesses;
  final List<String> currentGuess;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = constraints.maxWidth < 350 ? 5.0 : 7.0;
        final widthSize =
            (constraints.maxWidth - gap * (answerLength - 1)) / answerLength;
        final heightSize = constraints.hasBoundedHeight
            ? (constraints.maxHeight - gap * (maxGuesses - 1)) / maxGuesses
            : 60.0;
        final tileSize = widthSize < heightSize ? widthSize : heightSize;
        final safeTileSize = tileSize.clamp(38.0, 60.0).toDouble();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(maxGuesses, (row) {
            return Padding(
              padding: EdgeInsets.only(bottom: row == maxGuesses - 1 ? 0 : gap),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(answerLength, (column) {
                  String token = '';
                  TileScore? score;
                  var isFilled = false;

                  if (row < guesses.length) {
                    final guess = guesses[row];
                    if (column < guess.tokens.length) token = guess.tokens[column];
                    if (column < guess.scores.length) score = guess.scores[column];
                  } else if (row == guesses.length && column < currentGuess.length) {
                    token = currentGuess[column];
                    isFilled = true;
                  }

                  return Padding(
                    padding: EdgeInsets.only(
                      right: column == answerLength - 1 ? 0 : gap,
                    ),
                    child: _Tile(
                      size: safeTileSize,
                      token: token,
                      score: score,
                      filled: isFilled,
                      revealDelay: Duration(milliseconds: 70 * column),
                    ),
                  );
                }),
              ),
            );
          }),
        );
      },
    );
  }
}

class _Tile extends StatefulWidget {
  const _Tile({
    required this.size,
    required this.token,
    required this.score,
    required this.filled,
    required this.revealDelay,
  });

  final double size;
  final String token;
  final TileScore? score;
  final bool filled;
  final Duration revealDelay;

  @override
  State<_Tile> createState() => _TileState();
}

class _TileState extends State<_Tile> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _angle;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 820),
    );
    _angle = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: math.pi * 2.03)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 92,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: math.pi * 2.03, end: math.pi * 2)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 8,
      ),
    ]).animate(_controller);

    // Restored guesses should appear settled rather than replaying every time.
    if (widget.score != null) _controller.value = 1;
  }

  @override
  void didUpdateWidget(covariant _Tile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score == null && widget.score != null) {
      _delayTimer?.cancel();
      _controller.value = 0;
      _delayTimer = Timer(widget.revealDelay, () {
        if (mounted) _controller.forward(from: 0);
      });
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var background = DyfalaPalette.white;
    var border = DyfalaPalette.tileBorder;
    var foreground = DyfalaPalette.navy;

    switch (widget.score) {
      case TileScore.correct:
        background = DyfalaPalette.greenLight;
        border = DyfalaPalette.greenLight;
        foreground = Colors.white;
        break;
      case TileScore.present:
        background = DyfalaPalette.yellow;
        border = DyfalaPalette.yellow;
        break;
      case TileScore.absent:
        background = DyfalaPalette.absent;
        border = DyfalaPalette.absent;
        foreground = Colors.white;
        break;
      case null:
        if (widget.filled) border = DyfalaPalette.yellow;
        break;
    }

    final tile = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: widget.size,
      height: widget.size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(DyfalaSizes.tileRadius),
        border: Border.all(color: border, width: 1.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11071A27),
            offset: Offset(0, 2),
            blurRadius: 3,
          ),
        ],
      ),
      child: Text(
        widget.token,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w900,
          fontSize: widget.token.length > 1 ? widget.size * .34 : widget.size * .43,
          letterSpacing: -.8,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: _angle,
      child: tile,
      builder: (context, child) {
        final transform = Matrix4.identity()
          ..setEntry(3, 2, .0012)
          ..rotateY(_angle.value);
        return Transform(
          alignment: Alignment.center,
          transform: transform,
          child: child,
        );
      },
    );
  }
}
