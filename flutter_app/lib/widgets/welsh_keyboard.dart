import 'package:flutter/material.dart';

import '../game/game_engine.dart';
import '../theme/dyfala_theme.dart';

class WelshKeyboard extends StatelessWidget {
  const WelshKeyboard({
    super.key,
    required this.states,
    required this.onToken,
    required this.onDelete,
    required this.onSubmit,
  });

  final Map<String, TileScore> states;
  final ValueChanged<String> onToken;
  final VoidCallback onDelete;
  final VoidCallback onSubmit;

  static const _rows = <List<String>>[
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: List.generate(welshDigraphs.length, (index) {
            final token = welshDigraphs[index];
            const colours = [
              DyfalaPalette.red,
              DyfalaPalette.yellow,
              DyfalaPalette.green,
            ];
            final base = colours[index % colours.length];
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index == welshDigraphs.length - 1 ? 0 : 4),
                child: _Key(
                  label: token,
                  compact: true,
                  background: _stateColour(states[token]) ?? base,
                  foreground: base == DyfalaPalette.yellow
                      ? DyfalaPalette.navy
                      : Colors.white,
                  onTap: () => onToken(token),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 7),
        _LetterRow(tokens: _rows[0], states: states, onToken: onToken),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: _LetterRow(tokens: _rows[1], states: states, onToken: onToken),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            SizedBox(
              width: 60,
              child: _Key(
                label: 'Delete',
                action: true,
                background: DyfalaPalette.green,
                foreground: Colors.white,
                onTap: onDelete,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: _LetterRow(tokens: _rows[2], states: states, onToken: onToken),
            ),
            const SizedBox(width: 5),
            SizedBox(
              width: 60,
              child: _Key(
                label: 'Enter',
                action: true,
                background: DyfalaPalette.red,
                foreground: Colors.white,
                onTap: onSubmit,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Color? _stateColour(TileScore? score) {
    switch (score) {
      case TileScore.correct:
        return DyfalaPalette.greenLight;
      case TileScore.present:
        return DyfalaPalette.yellow;
      case TileScore.absent:
        return DyfalaPalette.absent;
      case null:
        return null;
    }
  }
}

class _LetterRow extends StatelessWidget {
  const _LetterRow({required this.tokens, required this.states, required this.onToken});

  final List<String> tokens;
  final Map<String, TileScore> states;
  final ValueChanged<String> onToken;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(tokens.length, (index) {
        final token = tokens[index];
        final score = states[token];
        var background = DyfalaPalette.white;
        var foreground = DyfalaPalette.navy;
        if (score != null) {
          background = WelshKeyboard._stateColour(score)!;
          if (score != TileScore.present) foreground = Colors.white;
        }
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == tokens.length - 1 ? 0 : 4),
            child: _Key(
              label: token,
              background: background,
              foreground: foreground,
              onTap: () => onToken(token),
            ),
          ),
        );
      }),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({
    this.label,
    this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.compact = false,
    this.action = false,
  });

  final String? label;
  final IconData? icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;
  final bool compact;
  final bool action;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(DyfalaSizes.keyRadius),
      elevation: background == DyfalaPalette.white ? .4 : 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DyfalaSizes.keyRadius),
        child: SizedBox(
          height: compact ? 35 : 46,
          child: Center(
            child: icon != null
                ? Icon(icon, color: foreground, size: 23)
                : FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: foreground,
                        fontSize: action ? 11 : (compact ? 11 : 14),
                        height: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
