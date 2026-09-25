import 'dart:io';

import 'package:flutter/foundation.dart';

/// Keeps Dyfala's ad experience deliberately light-touch.
///
/// Development builds use Google's sample banner IDs. Production IDs are
/// intentionally left unset until the AdMob app is ready to publish.
class AdService {
  AdService._();

  static final AdService instance = AdService._();

  bool _shownThisSession = false;

  bool get shouldShowAdBreak => !_shownThisSession && bannerAdUnitId != null;

  String? get bannerAdUnitId {
    if (!kDebugMode) return null;
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/9214589741';
    }
    if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2435281174';
    }
    return null;
  }

  void markAdBreakShown() {
    _shownThisSession = true;
  }
}
