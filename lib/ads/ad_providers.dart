import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'interstitial_ad_manager.dart';
import 'rewarded_ad_manager.dart';
import 'rewarded_interstitial_ad_manager.dart';

final interstitialAdProvider = Provider<InterstitialAdManager>((ref) {
  final manager = InterstitialAdManager();
  manager.loadAd();
  ref.onDispose(() => manager.dispose());
  return manager;
});

final rewardedAdProvider = Provider<RewardedAdManager>((ref) {
  final manager = RewardedAdManager();
  manager.loadAd();
  ref.onDispose(() => manager.dispose());
  return manager;
});

final rewardedInterstitialAdProvider =
Provider<RewardedInterstitialAdManager>((ref) {
  final manager = RewardedInterstitialAdManager();
  manager.loadAd();
  ref.onDispose(() => manager.dispose());
  return manager;
});