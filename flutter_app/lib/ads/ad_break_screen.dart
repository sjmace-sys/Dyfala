import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../localisation/app_language.dart';
import '../theme/dyfala_theme.dart';
import 'ad_service.dart';

class AdBreakScreen extends StatefulWidget {
  const AdBreakScreen({super.key, required this.language});

  final UiLanguage language;

  @override
  State<AdBreakScreen> createState() => _AdBreakScreenState();
}

class _AdBreakScreenState extends State<AdBreakScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _timer;
  bool _ready = false;

  bool get _isWelsh => widget.language == UiLanguage.welsh;

  @override
  void initState() {
    super.initState();

    _timer = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() => _ready = true);
        }
      })
      ..forward();

    AdService.instance.markAdBreakShown();
  }

  @override
  void dispose() {
    _timer.dispose();
    super.dispose();
  }

  void _play() {
    if (!_ready) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final advertLabel = _isWelsh ? 'HYSBYSEB' : 'ADVERTISEMENT';
    final waitingLabel =
        _isWelsh ? 'Mae dy air bron yn barod…' : 'Your word is nearly ready…';
    final playLabel = _isWelsh ? 'Chwarae' : 'Play';

    return Scaffold(
      backgroundColor: DyfalaPalette.cream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 56,
                    child: Image.asset(
                      'assets/approved/home-logo.png',
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    advertLabel,
                    style: GoogleFonts.nunitoSans(
                      color: DyfalaPalette.inkSoft,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 332,
                    height: 282,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x18071A27),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/mock_ads/mock_ad_wales.png',
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedBuilder(
                    animation: _timer,
                    builder: (context, _) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          value: _timer.value,
                          backgroundColor: Colors.white.withOpacity(.85),
                          color: DyfalaPalette.yellow,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _ready
                        ? SizedBox(
                            key: const ValueKey('play'),
                            width: double.infinity,
                            height: 58,
                            child: FilledButton(
                              onPressed: _play,
                              style: FilledButton.styleFrom(
                                backgroundColor: DyfalaPalette.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    playLabel,
                                    style: GoogleFonts.fredoka(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded),
                                ],
                              ),
                            ),
                          )
                        : Padding(
                            key: const ValueKey('waiting'),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              waitingLabel,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunitoSans(
                                color: DyfalaPalette.navy,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
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
