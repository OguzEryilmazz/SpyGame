import 'dart:io';

import 'package:flutter/foundation.dart';

class AdIds {
  AdIds._();

  // ── Android production IDs ────────────────────────────────────────────────
  static const String _prodBannerAndroid =
      'ca-app-pub-2309411454414388/5016349532';
  static const String _prodInterstitialAndroid =
      'ca-app-pub-2309411454414388/4262876347';
  static const String _prodRewardedAndroid =
      'ca-app-pub-2309411454414388/4373405600';

  // ── iOS production IDs (fill in after AdMob iOS setup) ───────────────────
  static const String _prodBannerIos =
      'ca-app-pub-3940256099942544/2934735716'; // test until provisioned
  static const String _prodInterstitialIos =
      'ca-app-pub-3940256099942544/4411468910';
  static const String _prodRewardedIos =
      'ca-app-pub-3940256099942544/1712485313';

  // ── Google test IDs ───────────────────────────────────────────────────────
  static const String _testBannerAndroid =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerIos =
      'ca-app-pub-3940256099942544/2934735716';
  static const String _testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIos =
      'ca-app-pub-3940256099942544/4411468910';
  static const String _testRewardedAndroid =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testRewardedIos =
      'ca-app-pub-3940256099942544/1712485313';

  // ── Resolved getters ──────────────────────────────────────────────────────

  static String get bannerId {
    if (Platform.isAndroid) {
      return kReleaseMode ? _prodBannerAndroid : _testBannerAndroid;
    }
    return kReleaseMode ? _prodBannerIos : _testBannerIos;
  }

  static String get interstitialId {
    if (Platform.isAndroid) {
      return kReleaseMode ? _prodInterstitialAndroid : _testInterstitialAndroid;
    }
    return kReleaseMode ? _prodInterstitialIos : _testInterstitialIos;
  }

  static String get rewardedId {
    if (Platform.isAndroid) {
      return kReleaseMode ? _prodRewardedAndroid : _testRewardedAndroid;
    }
    return kReleaseMode ? _prodRewardedIos : _testRewardedIos;
  }
}
