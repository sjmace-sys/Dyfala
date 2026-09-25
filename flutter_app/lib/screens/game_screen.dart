import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../game/game_controller.dart';
import '../game/game_engine.dart';
import '../theme/dyfala_theme.dart';
import '../widgets/tile_board.dart';
import '../widgets/welsh_keyboard.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key, required this.controller});

  final GameController controller;

  String _backgroundAsset() {
    return controller.uiLanguage.name == 'welsh'
        ? 'assets/approved/home-cy.png'
        : 'assets/approved/home-en.png';
  }

  void _showInvalidWordMessage(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: IgnorePointer(
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 310),
                margin: const EdgeInsets.symmetric(horizontal: 28),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFCF6),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: DyfalaPalette.red.withOpacity(.22), width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x30071A27),
                      blurRadius: 26,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sentiment_dissatisfied_rounded, color: DyfalaPalette.red, size: 29),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                          color: DyfalaPalette.navy,
                          fontSize: 17,
                          height: 1.15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (entry.mounted) entry.remove();
    });
  }

  Future<void> _showNextHint(BuildContext context) async {
    final hint = await controller.revealNextHint();
    if (hint == null || !context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierColor: DyfalaPalette.navy.withOpacity(.42),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: _HintCard(
            hint: hint,
            closeLabel: controller.strings.close,
            starsLabel: controller.strings.starsStillAvailable(hint.starsRemaining),
            onClose: () => Navigator.of(dialogContext).pop(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = keyboardState(controller.guesses);
    final strings = controller.strings;

    return Scaffold(
      backgroundColor: DyfalaPalette.cream,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              _backgroundAsset(),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              filterQuality: FilterQuality.high,
            ),
          ),
          Positioned.fill(
            child: Container(color: DyfalaPalette.cream.withOpacity(.80)),
          ),
          SafeArea(
            bottom: true,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                  child: Row(
                    children: [
                      _RoundIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: controller.goHome,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Center(
                          child: SizedBox(
                            height: 42,
                            child: Image.asset(
                              'assets/approved/home-logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const SizedBox(width: 44),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.84),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14071A27),
                          blurRadius: 14,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _AvailableStars(stars: controller.starsAvailable),
                            const Spacer(),
                            _HintButton(
                              enabled: controller.canUseHint,
                              label: controller.canUseHint
                                  ? strings.hintButton(controller.hintsUsed + 1)
                                  : strings.noMoreHints,
                              onTap: () => _showNextHint(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final boardPadding = constraints.maxHeight < 500 ? 8.0 : 14.0;
                      return Padding(
                        padding: EdgeInsets.fromLTRB(18, boardPadding, 18, 8),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 370),
                            child: _BoardShake(
                              trigger: controller.invalidWordTick,
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(.92),
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x16071A27),
                                      blurRadius: 18,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: TileBoard(
                                  answerLength: controller.answerTokens.length,
                                  guesses: controller.guesses,
                                  currentGuess: controller.currentGuess,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 9, 8, 10),
                  decoration: const BoxDecoration(
                    color: DyfalaPalette.creamDeep,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: WelshKeyboard(
                    states: keyboard,
                    onToken: (token) => controller.addToken(token),
                    onDelete: () => controller.backspace(),
                    onSubmit: () async {
                      final message = await controller.submitGuess();
                      if (!context.mounted) return;
                      if (controller.lastSubmitWasInvalidWord && message != null) {
                        await HapticFeedback.vibrate();
                        if (context.mounted) _showInvalidWordMessage(context, message);
                        return;
                      }
                      if (message != null && context.mounted) {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text(message),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: DyfalaPalette.navy,
                            ),
                          );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(.92),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: DyfalaPalette.navy, size: 20),
        ),
      ),
    );
  }
}

class _AvailableStars extends StatelessWidget {
  const _AvailableStars({required this.stars});

  final int stars;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.96),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return Icon(
            index < stars ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 20,
            color: index < stars ? DyfalaPalette.yellow : DyfalaPalette.absent,
          );
        }),
      ),
    );
  }
}

class _HintButton extends StatelessWidget {
  const _HintButton({
    required this.enabled,
    required this.label,
    required this.onTap,
  });

  final bool enabled;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          width: 126,
          height: 38,
          decoration: BoxDecoration(
            color: enabled ? DyfalaPalette.yellow : Colors.white.withOpacity(.90),
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [
              BoxShadow(color: Color(0x12071A27), blurRadius: 8, offset: Offset(0, 3)),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 10,
                child: Icon(
                  Icons.lightbulb_rounded,
                  color: enabled ? DyfalaPalette.navy : DyfalaPalette.absent,
                  size: 18,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: GoogleFonts.nunitoSans(
                        color: enabled ? DyfalaPalette.navy : DyfalaPalette.absent,
                        fontSize: 12,
                        height: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard({
    required this.hint,
    required this.closeLabel,
    required this.starsLabel,
    required this.onClose,
  });

  final HintMessage hint;
  final String closeLabel;
  final String starsLabel;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF6),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(color: Color(0x26071A27), blurRadius: 28, offset: Offset(0, 14)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  hint.title,
                  style: GoogleFonts.fredoka(
                    color: DyfalaPalette.navy,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Material(
                color: DyfalaPalette.red.withOpacity(.12),
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(999),
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(Icons.close_rounded, color: DyfalaPalette.red),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              hint.body,
              style: GoogleFonts.nunitoSans(
                color: DyfalaPalette.navy,
                fontSize: 17,
                height: 1.35,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: DyfalaPalette.yellow, size: 22),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  starsLabel,
                  style: GoogleFonts.nunitoSans(
                    color: DyfalaPalette.greenDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: onClose,
              style: FilledButton.styleFrom(
                backgroundColor: DyfalaPalette.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              child: Text(
                closeLabel,
                style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BoardShake extends StatefulWidget {
  const _BoardShake({required this.trigger, required this.child});

  final int trigger;
  final Widget child;

  @override
  State<_BoardShake> createState() => _BoardShakeState();
}

class _BoardShakeState extends State<_BoardShake> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offset;
  int _lastTrigger = 0;

  @override
  void initState() {
    super.initState();
    _lastTrigger = widget.trigger;
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 360));
    _offset = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: 0), weight: 3),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant _BoardShake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != _lastTrigger) {
      _lastTrigger = widget.trigger;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offset,
      builder: (context, child) {
        return Transform.translate(offset: Offset(_offset.value, 0), child: child);
      },
      child: widget.child,
    );
  }
}
