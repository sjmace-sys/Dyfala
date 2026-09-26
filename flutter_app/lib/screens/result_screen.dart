import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../game/game_controller.dart';
import '../game/game_engine.dart';
import '../share/share_image.dart';
import '../theme/dyfala_theme.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.controller});

  final GameController controller;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  Timer? _timer;

  String _backgroundAsset() {
    return widget.controller.uiLanguage.name == 'welsh'
        ? 'assets/approved/home-cy.png'
        : 'assets/approved/home-en.png';
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _share(BuildContext context) async {
    final controller = widget.controller;
    try {
      final image = await DyfalaShareImage.create(controller);
      await Share.shareXFiles([XFile(image.path)]);
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: controller.shareText()));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.strings.shareImageError),
          behavior: SnackBarBehavior.floating,
          backgroundColor: DyfalaPalette.navy,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final strings = controller.strings;
    final remaining = controller.untilTomorrow;
    final hours = remaining.inHours.toString().padLeft(2, '0');
    final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    final clock = '$hours:$minutes:$seconds';

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
            child: Container(color: DyfalaPalette.cream.withOpacity(.84)),
          ),
          const Positioned(
            left: 18,
            top: 118,
            child: _DecorDot(size: 42, colour: DyfalaPalette.yellow),
          ),
          const Positioned(
            right: 18,
            top: 150,
            child: Icon(Icons.auto_awesome_rounded, color: DyfalaPalette.red, size: 34),
          ),
          const Positioned(
            left: 28,
            bottom: 68,
            child: Icon(Icons.eco_rounded, color: DyfalaPalette.greenLight, size: 38),
          ),
          const Positioned(
            right: 26,
            bottom: 108,
            child: _DecorDot(size: 28, colour: DyfalaPalette.red),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                      child: Row(
                        children: [
                          _RoundIconButton(
                            icon: Icons.arrow_back_rounded,
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
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 390),
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFDF8).withOpacity(.96),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(color: DyfalaPalette.yellow.withOpacity(.30), width: 1.4),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x16071A27),
                                    blurRadius: 24,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    controller.won ? strings.wellDone : strings.todaysAnswer,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.fredoka(
                                      color: DyfalaPalette.navy,
                                      fontSize: constraints.maxHeight < 700 ? 28 : 32,
                                      height: 1,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  _ResultStars(
                                    stars: controller.resultStars,
                                    hintsText: strings.hintsUsedText(controller.hintsUsed),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    controller.practiceMode
                                        ? '${strings.practiceMode} · ${controller.learnerStage}'
                                        : controller.won
                                            ? strings.attempts(controller.guesses.length, controller.puzzleNumber)
                                            : strings.tryAgainTomorrow(controller.puzzleNumber),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.nunitoSans(
                                      color: DyfalaPalette.inkSoft,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  _LearningCard(controller: controller),
                                  const SizedBox(height: 12),
                                  if (!controller.practiceMode)
                                    Text(
                                      strings.nextWord(clock),
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.nunitoSans(
                                        color: DyfalaPalette.greenDark,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  if (!controller.practiceMode) const SizedBox(height: 10),
                                  _CenteredActionButton(
                                    label: strings.share,
                                    icon: Icons.ios_share_rounded,
                                    colour: DyfalaPalette.red,
                                    onTap: () => _share(context),
                                  ),
                                  const SizedBox(height: 10),
                                  _CenteredActionButton(
                                    label: strings.tryAnother,
                                    icon: Icons.refresh_rounded,
                                    colour: DyfalaPalette.green,
                                    onTap: controller.tryAnotherWord,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorDot extends StatelessWidget {
  const _DecorDot({required this.size, required this.colour});

  final double size;
  final Color colour;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colour.withOpacity(.20),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _CenteredActionButton extends StatelessWidget {
  const _CenteredActionButton({
    required this.label,
    required this.icon,
    required this.colour,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color colour;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colour,
      borderRadius: BorderRadius.circular(999),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 20,
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredoka(
                        color: Colors.white,
                        fontSize: 18,
                        height: 1,
                        fontWeight: FontWeight.w600,
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

class _ResultStars extends StatelessWidget {
  const _ResultStars({required this.stars, required this.hintsText});

  final int stars;
  final String hintsText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Icon(
              index < stars ? Icons.star_rounded : Icons.star_outline_rounded,
              color: index < stars ? DyfalaPalette.yellow : DyfalaPalette.absent,
              size: 32,
            );
          }),
        ),
        const SizedBox(height: 2),
        Text(
          hintsText,
          style: GoogleFonts.nunitoSans(
            color: DyfalaPalette.inkSoft,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _LearningCard extends StatelessWidget {
  const _LearningCard({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final strings = controller.strings;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
            decoration: BoxDecoration(
              color: DyfalaPalette.yellow.withOpacity(.22),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              strings.whatLearned,
              style: GoogleFonts.nunitoSans(
                color: DyfalaPalette.navy,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            controller.puzzle.answer,
            style: GoogleFonts.fredoka(
              color: DyfalaPalette.navy,
              fontSize: 34,
              height: 1,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            strings.englishMeaning.toUpperCase(),
            style: GoogleFonts.nunitoSans(
              color: DyfalaPalette.red,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            controller.puzzle.meaning,
            textAlign: TextAlign.center,
            style: GoogleFonts.fredoka(
              color: DyfalaPalette.navy,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Text(
            strings.welshExample.toUpperCase(),
            style: GoogleFonts.nunitoSans(
              color: DyfalaPalette.green,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            controller.puzzle.exampleCy,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunitoSans(
              color: DyfalaPalette.navy,
              fontSize: 16,
              height: 1.25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            controller.puzzle.exampleEn,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunitoSans(
              color: DyfalaPalette.inkSoft,
              fontSize: 13,
              height: 1.25,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
