import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Handles Dyfala's light-touch ad experience.
///
/// Development builds deliberately use Google's sample interstitial IDs.
/// Replace the production IDs before publishing to the stores.
class AdService {
  AdService._();

  static final AdService instance = AdService._();

  InterstitialAd? _interstitial;
  bool _isLoading = false;
  bool _shownThisSession = false;

  String? get _adUnitId {
    if (!kDebugMode) return null;
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712';
    }
    if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    return null;
  }

  void preload() {
    final adUnitId = _adUnitId;
    if (adUnitId == null || _interstitial != null || _isLoading || _shownThisSession) {
      return;
    }

    _isLoading = true;
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoading = false;
          _interstitial = ad;
        },
        onAdFailedToLoad: (_) {
          _isLoading = false;
          _interstitial = null;
        },
      ),
    );
  }

  void showBeforeGame({required VoidCallback onComplete}) {
    if (_shownThisSession) {
      onComplete();
      return;
    }

    final ad = _interstitial;
    if (ad == null) {
      preload();
      onComplete();
      return;
    }

    _shownThisSession = true;
    _interstitial = null;

    var completed = false;
    void finish() {
      if (completed) return;
      completed = true;
      onComplete();
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (shownAd) {
        shownAd.dispose();
        finish();
      },
      onAdFailedToShowFullScreenContent: (shownAd, _) {
        shownAd.dispose();
        finish();
      },
    );

    ad.show();
  }

  void dispose() {
    _interstitial?.dispose();
    _interstitial = null;
  }
}
