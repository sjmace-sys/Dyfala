import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../ads/ad_break_screen.dart';
import '../ads/ad_service.dart';
import '../game/game_controller.dart';
import '../localisation/app_language.dart';
import '../theme/dyfala_theme.dart';
import '../widgets/language_toggle.dart';
import '../widgets/approved_logo.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final strings = controller.strings;
    final stats = controller.stats;

    return Scaffold(
      backgroundColor: DyfalaPalette.cream,
      body: Stack(
        children: [
          Positioned(
            left: -3,
            right: -3,
            top: -3,
            bottom: -3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/approved/home-en.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  filterQuality: FilterQuality.high,
                ),
                IgnorePointer(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 140),
                    opacity: controller.uiLanguage == UiLanguage.welsh ? 1 : 0,
                    child: const _WelshHomeCopyOverlay(),
                  ),
                ),
                const _WelshSignpostOverlay(),
              ],
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 10,
                  left: 16,
                  child: _FloatingCircleButton(
                    icon: Icons.question_mark_rounded,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => _HelpPage(controller: controller),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 16,
                  child: LanguageToggle(
                    language: controller.uiLanguage,
                    onChanged: controller.setLanguage,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _StatsCard(
                          played: stats.played,
                          winRate: stats.played == 0
                              ? 0
                              : ((stats.wins / stats.played) * 100).round(),
                          streak: stats.streak,
                          best: stats.totalStars,
                          labels: _StatsLabels(
                            played: strings.played,
                            winRate: strings.winRate,
                            streak: strings.streak,
                            best: strings.stars,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _PrimaryActionButton(
                          label: controller.homeButtonLabel,
                          onTap: () async {
                            if (controller.gameOver) {
                              controller.startOrResume();
                              return;
                            }

                            if (!AdService.instance.shouldShowAdBreak) {
                              controller.startOrResume();
                              return;
                            }

                            final play = await Navigator.of(context).push<bool>(
                              MaterialPageRoute<bool>(
                                builder: (_) => AdBreakScreen(
                                  language: controller.uiLanguage,
                                ),
                              ),
                            );

                            if (play == true && context.mounted) {
                              controller.startOrResume();
                            }
                          },
                        ),
                      ],
                    ),
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

class _WelshHomeCopyOverlay extends StatelessWidget {
  const _WelshHomeCopyOverlay();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipPath(
          clipper: const _WelshMainCopyClipper(),
          child: Image.asset(
            'assets/approved/home-cy.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            filterQuality: FilterQuality.high,
            gaplessPlayback: true,
          ),
        ),
        const _WelshSidePhrase(),
      ],
    );
  }
}

class _WelshMainCopyClipper extends CustomClipper<Path> {
  const _WelshMainCopyClipper();

  static const double _sourceWidth = 941;
  static const double _sourceHeight = 1672;

  @override
  Path getClip(Size size) {
    final scale = math.max(
      size.width / _sourceWidth,
      size.height / _sourceHeight,
    );
    final renderedWidth = _sourceWidth * scale;
    final dx = (size.width - renderedWidth) / 2;

    Rect mapRect(double left, double top, double right, double bottom) {
      return Rect.fromLTRB(
        dx + left * scale,
        top * scale,
        dx + right * scale,
        bottom * scale,
      );
    }

    return Path()..addRect(mapRect(125, 292, 825, 552));
  }

  @override
  bool shouldReclip(covariant _WelshMainCopyClipper oldClipper) => false;
}

class _WelshSidePhrase extends StatelessWidget {
  const _WelshSidePhrase();

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: 941,
        height: 1672,
        child: Stack(
          children: [
            Positioned(
              left: 500,
              top: 560,
              width: 350,
              height: 185,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: .90,
                    colors: [
                      DyfalaPalette.cream,
                      DyfalaPalette.cream,
                      DyfalaPalette.cream.withOpacity(.98),
                      DyfalaPalette.cream.withOpacity(0),
                    ],
                    stops: const [0, .56, .76, 1],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 525,
              top: 594,
              width: 295,
              child: Transform.rotate(
                angle: -.055,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dysga air.',
                      style: GoogleFonts.fredoka(
                        color: DyfalaPalette.navy,
                        fontSize: 39,
                        height: .96,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Gwena fwy.',
                      style: GoogleFonts.fredoka(
                        color: DyfalaPalette.navy,
                        fontSize: 39,
                        height: .96,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 238,
                      height: 8,
                      decoration: BoxDecoration(
                        color: DyfalaPalette.red,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelshSignpostOverlay extends StatelessWidget {
  const _WelshSignpostOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: FittedBox(
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 941,
          height: 1672,
          child: Stack(
            children: [
              // Rebuild the whole signpost as one illustration so the three
              // boards belong together and the baked-in old third label is
              // completely covered in both EN and CY modes.
              Positioned(
                left: 108,
                top: 706,
                width: 70,
                height: 360,
                child: Transform.rotate(
                  angle: .012,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFF8A4A1D),
                          Color(0xFFB86C2C),
                          Color(0xFF8E4C1E),
                        ],
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x28071A27),
                          blurRadius: 6,
                          offset: Offset(3, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Positioned(
                left: -12,
                top: 748,
                child: _IllustratedSign(
                  text: 'DYSGU',
                  width: 390,
                  height: 82,
                  start: Color(0xFFE51D2E),
                  end: Color(0xFFC91527),
                  foreground: Colors.white,
                  angle: -.018,
                ),
              ),
              const Positioned(
                left: -4,
                top: 836,
                child: _IllustratedSign(
                  text: 'CHWARAE',
                  width: 398,
                  height: 82,
                  start: Color(0xFF0BA56F),
                  end: Color(0xFF07885D),
                  foreground: Colors.white,
                  angle: -.010,
                ),
              ),
              const Positioned(
                left: -10,
                top: 924,
                child: _IllustratedSign(
                  text: 'RHANNU',
                  width: 410,
                  height: 82,
                  start: Color(0xFFFFD04B),
                  end: Color(0xFFF5B82C),
                  foreground: DyfalaPalette.navy,
                  angle: -.014,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IllustratedSign extends StatelessWidget {
  const _IllustratedSign({
    required this.text,
    required this.width,
    required this.height,
    required this.start,
    required this.end,
    required this.foreground,
    required this.angle,
  });

  final String text;
  final double width;
  final double height;
  final Color start;
  final Color end;
  final Color foreground;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0x26071A27),
                blurRadius: 6,
                offset: Offset(2, 4),
              ),
            ],
          ),
          child: ClipPath(
            clipper: const _SignArrowClipper(),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [start, end],
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    left: 18,
                    right: 70,
                    top: 15,
                    child: Container(
                      height: 2,
                      color: Colors.white.withOpacity(.10),
                    ),
                  ),
                  Positioned(
                    left: 26,
                    right: 88,
                    bottom: 15,
                    child: Container(
                      height: 2,
                      color: const Color(0xFF5F3A18).withOpacity(.10),
                    ),
                  ),
                  Positioned(
                    left: 31,
                    top: 21,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5F3A18).withOpacity(.18),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 82,
                    bottom: 20,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5F3A18).withOpacity(.16),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 32,
                    right: 74,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          text,
                          maxLines: 1,
                          style: GoogleFonts.fredoka(
                            color: foreground,
                            fontSize: 43,
                            height: 1,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .25,
                            shadows: const [
                              Shadow(
                                color: Color(0x22071A27),
                                offset: Offset(0, 1),
                                blurRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SignArrowClipper extends CustomClipper<Path> {
  const _SignArrowClipper();

  @override
  Path getClip(Size size) {
    final tip = size.height * .74;
    return Path()
      ..moveTo(0, 3)
      ..quadraticBezierTo(0, 0, 4, 0)
      ..lineTo(size.width - tip, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width - tip, size.height)
      ..lineTo(4, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - 4)
      ..close();
  }

  @override
  bool shouldReclip(covariant _SignArrowClipper oldClipper) => false;
}

class _HelpPage extends StatelessWidget {
  const _HelpPage({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final strings = controller.strings;
        return Scaffold(
          backgroundColor: DyfalaPalette.cream,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
                  child: Row(
                    children: [
                      _FloatingCircleButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Center(
                          child: const ApprovedDyfalaLogo(
                            height: 56,
                            maxWidth: 180,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Transform.scale(
                        scale: .88,
                        alignment: Alignment.centerRight,
                        child: LanguageToggle(
                          language: controller.uiLanguage,
                          onChanged: controller.setLanguage,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            width: 390,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: DyfalaPalette.red,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      strings.helpTitle,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.fredoka(
                                        color: Colors.white,
                                        fontSize: 22,
                                        height: 1,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 9),
                                Text(
                                  strings.helpIntro,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.nunitoSans(
                                    color: DyfalaPalette.navy,
                                    fontSize: 13.2,
                                    height: 1.22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 9),
                                const _HelpGrid(),
                                const SizedBox(height: 10),
                                _HelpRule(colour: DyfalaPalette.greenLight, text: strings.helpCorrect),
                                _HelpRule(colour: DyfalaPalette.yellow, text: strings.helpPresent),
                                _HelpRule(colour: const Color(0xFF8A9395), text: strings.helpAbsent),
                                const SizedBox(height: 4),
                                _HelpInfoCard(
                                  icon: Icons.extension_rounded,
                                  iconColour: DyfalaPalette.greenLight,
                                  text: strings.helpDigraph,
                                ),
                                const SizedBox(height: 5),
                                _HelpInfoCard(
                                  icon: Icons.menu_book_rounded,
                                  iconColour: DyfalaPalette.yellow,
                                  text: strings.helpLearner,
                                ),
                                const SizedBox(height: 5),
                                _HelpInfoCard(
                                  icon: Icons.lightbulb_rounded,
                                  iconColour: DyfalaPalette.greenLight,
                                  text: strings.helpHints,
                                ),
                                const SizedBox(height: 5),
                                _HelpInfoCard(
                                  icon: Icons.calendar_month_rounded,
                                  iconColour: DyfalaPalette.red,
                                  text: strings.helpDaily,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HelpGrid extends StatelessWidget {
  const _HelpGrid();

  @override
  Widget build(BuildContext context) {
    const absent = Color(0xFF8A9395);
    const border = Color(0xFFD9CEBC);

    Widget row(List<String> letters, List<Color?> colours) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          return Padding(
            padding: EdgeInsets.only(right: index == 4 ? 0 : 4),
            child: _HelpTile(
              letter: letters[index],
              colour: colours[index],
              borderColour: border,
            ),
          );
        }),
      );
    }

    return Column(
      children: [
        row(
          const ['P', 'L', 'A', 'N', 'T'],
          const [absent, DyfalaPalette.greenLight, DyfalaPalette.yellow, absent, absent],
        ),
        const SizedBox(height: 4),
        row(
          const ['C', 'Y', 'M', 'R', 'U'],
          const [
            DyfalaPalette.greenLight,
            DyfalaPalette.greenLight,
            DyfalaPalette.greenLight,
            DyfalaPalette.greenLight,
            DyfalaPalette.greenLight,
          ],
        ),
        for (var i = 0; i < 4; i++) ...[
          const SizedBox(height: 4),
          row(const ['', '', '', '', ''], const [null, null, null, null, null]),
        ],
      ],
    );
  }
}

class _HelpTile extends StatelessWidget {
  const _HelpTile({
    required this.letter,
    required this.colour,
    required this.borderColour,
  });

  final String letter;
  final Color? colour;
  final Color borderColour;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colour ?? const Color(0xFFFFFCF6),
        borderRadius: BorderRadius.circular(7),
        border: colour == null ? Border.all(color: borderColour, width: 1.2) : null,
      ),
      child: Text(
        letter,
        style: GoogleFonts.fredoka(
          color: colour == null ? DyfalaPalette.navy : Colors.white,
          fontSize: 16,
          height: 1,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _HelpRule extends StatelessWidget {
  const _HelpRule({required this.colour, required this.text});

  final Color colour;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: colour,
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.nunitoSans(
                color: DyfalaPalette.navy,
                fontSize: 12.4,
                height: 1.14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpInfoCard extends StatelessWidget {
  const _HelpInfoCard({
    required this.icon,
    required this.iconColour,
    required this.text,
  });

  final IconData icon;
  final Color iconColour;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.94),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0C071A27), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: iconColour, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 17),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.nunitoSans(
                color: DyfalaPalette.navy,
                fontSize: 12.1,
                height: 1.16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsLabels {
  const _StatsLabels({
    required this.played,
    required this.winRate,
    required this.streak,
    required this.best,
  });

  final String played;
  final String winRate;
  final String streak;
  final String best;
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.played,
    required this.winRate,
    required this.streak,
    required this.best,
    required this.labels,
  });

  final int played;
  final int winRate;
  final int streak;
  final int best;
  final _StatsLabels labels;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 620),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.96),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14071A27),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.menu_book_rounded,
              colour: DyfalaPalette.greenLight,
              value: '$played',
              label: labels.played,
            ),
          ),
          const _DividerLine(),
          Expanded(
            child: _StatItem(
              icon: Icons.bar_chart_rounded,
              colour: DyfalaPalette.yellow,
              value: '$winRate%',
              label: labels.winRate,
            ),
          ),
          const _DividerLine(),
          Expanded(
            child: _StatItem(
              icon: Icons.local_fire_department_rounded,
              colour: DyfalaPalette.red,
              value: '$streak',
              label: labels.streak,
            ),
          ),
          const _DividerLine(),
          Expanded(
            child: _StatItem(
              icon: Icons.star_rounded,
              colour: DyfalaPalette.yellow,
              value: '$best',
              label: labels.best,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.colour,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color colour;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: colour, size: 19),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.fredoka(
            fontSize: 21,
            height: 1,
            fontWeight: FontWeight.w700,
            color: DyfalaPalette.navy,
          ),
        ),
        const SizedBox(height: 3),
        SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: GoogleFonts.nunitoSans(
                fontSize: 9.5,
                height: 1,
                fontWeight: FontWeight.w800,
                color: DyfalaPalette.inkSoft,
                letterSpacing: .3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 58,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: DyfalaPalette.tileBorder.withOpacity(.8),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Ink(
          width: double.infinity,
          height: 72,
          decoration: BoxDecoration(
            color: DyfalaPalette.red,
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26071A27),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 58),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredoka(
                        fontSize: 28,
                        height: 1,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const Positioned(
                right: 20,
                child: Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 34),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingCircleButton extends StatelessWidget {
  const _FloatingCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Ink(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: Color(0xF9FFFFFF),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x16071A27),
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Center(child: Icon(icon, size: 30, color: DyfalaPalette.navy)),
        ),
      ),
    );
  }
}
