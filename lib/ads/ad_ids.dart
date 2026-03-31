import 'dart:io';
import 'package:flutter/foundation.dart';

class AdIds {
  // iOS gerçek ID'ler
  static const String _iosBanner = 'ca-app-pub-2309411454414388/4647314918';
  static const String _iosInterstitial = 'ca-app-pub-2309411454414388/2119450421';
  static const String _iosRewarded = 'ca-app-pub-2309411454414388/8995849962';

  // Test ID'ler
  static const String _testBanner = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testInterstitial = 'ca-app-pub-3940256099942544/4411468910';
  static const String _testRewarded = 'ca-app-pub-3940256099942544/1712485313';

  static bool get _useReal => Platform.isIOS && !kDebugMode;

  static String get banner => _useReal ? _iosBanner : _testBanner;
  static String get interstitial => _useReal ? _iosInterstitial : _testInterstitial;
  static String get rewarded => _useReal ? _iosRewarded : _testRewarded;
}
