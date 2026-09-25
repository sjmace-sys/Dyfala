import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../ads/ad_service.dart';
import '../game/game_controller.dart';
import '../localisation/app_language.dart';
import '../theme/dyfala_theme.dart';
import '../widgets/language_toggle.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});

  final GameController controller;

  String _homeBackground(UiLanguage language) {
    return language == UiLanguage.welsh
        ? 'assets/approved/home-cy.png'
        : 'assets/approved/home-en.png';
  }

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
            child: Image.asset(
              _homeBackground(controller.uiLanguage),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              filterQuality: FilterQuality.high,
              gaplessPlayback: true,
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
                          onTap: () {
                            if (controller.gameOver) {
                              controller.startOrResume();
                              return;
                            }
                            AdService.instance.showBeforeGame(
                              onComplete: controller.startOrResume,
                            );
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
                          child: SizedBox(
                            width: 126,
                            height: 40,
                            child: Image.asset(
                              'assets/approved/home-logo.png',
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
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
