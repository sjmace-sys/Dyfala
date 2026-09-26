import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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
  BannerAd? _banner;
  bool _adLoaded = false;
  bool _ready = false;

  bool get _isWelsh => widget.language == UiLanguage.welsh;

  @override
  void initState() {
    super.initState();

    _timer = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() => _ready = true);
        }
      });

    final adUnitId = AdService.instance.bannerAdUnitId;
    if (adUnitId != null) {
      _banner = BannerAd(
        adUnitId: adUnitId,
        size: AdSize.mediumRectangle,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) {
            if (!mounted) return;
            setState(() => _adLoaded = true);
            _timer.forward(from: 0);
          },
          onAdFailedToLoad: (ad, _) {
            ad.dispose();
            if (mounted) {
              setState(() {
                _banner = null;
                _adLoaded = false;
                _ready = true;
              });
            }
          },
        ),
      )..load();
    }

    AdService.instance.markAdBreakShown();
  }

  @override
  void dispose() {
    _timer.dispose();
    _banner?.dispose();
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
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.96),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x18071A27),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: _adLoaded && _banner != null
                        ? SizedBox(
                            width: _banner!.size.width.toDouble(),
                            height: _banner!.size.height.toDouble(),
                            child: AdWidget(ad: _banner!),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.campaign_rounded,
                                color: DyfalaPalette.red,
                                size: 40,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _isWelsh
                                    ? 'Yn llwytho’r hysbyseb…'
                                    : 'Loading advert…',
                                style: GoogleFonts.nunitoSans(
                                  color: DyfalaPalette.navy,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
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
                          value: _adLoaded ? _timer.value : 0,
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
