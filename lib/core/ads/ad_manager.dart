import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_ids.dart';

/// Manages interstitial and rewarded ad lifecycles.
///
/// Banner ads are handled per-widget in [BannerAdWidget] since AdMob requires
/// one BannerAd instance per view.
///
/// Usage:
///   AdManager.instance.preloadAll();
///   AdManager.instance.showInterstitialWithCallback(() => navigate());
class AdManager {
  AdManager._();
  static final AdManager instance = AdManager._();

  // ── Interstitial ──────────────────────────────────────────────────────────

  InterstitialAd? _interstitial;
  bool _interstitialLoading = false;
  int _adShowCount = 0;

  void loadInterstitial() {
    if (_interstitialLoading || _interstitial != null) return;
    _interstitialLoading = true;

    InterstitialAd.load(
      adUnitId: AdIds.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _interstitialLoading = false;
          _interstitial!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitial = null;
              loadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitial = null;
              loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _interstitialLoading = false;
          Future.delayed(
            const Duration(seconds: 60),
            loadInterstitial,
          );
        },
      ),
    );
  }

  /// Shows interstitial with frequency control — every 2nd call shows an ad.
  /// [onComplete] is always called (after ad dismissed or immediately if skipped).
  void showInterstitialWithCallback(VoidCallback onComplete) {
    _adShowCount++;
    final shouldShow = _adShowCount % 2 == 0;

    if (!shouldShow || _interstitial == null) {
      onComplete();
      return;
    }

    _interstitial!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitial = null;
        loadInterstitial();
        onComplete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitial = null;
        loadInterstitial();
        onComplete();
      },
    );

    _interstitial!.show();
  }

  // ── Rewarded ──────────────────────────────────────────────────────────────

  RewardedAd? _rewarded;
  bool _rewardedLoading = false;

  void loadRewarded() {
    if (_rewardedLoading || _rewarded != null) return;
    _rewardedLoading = true;

    RewardedAd.load(
      adUnitId: AdIds.rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewarded = ad;
          _rewardedLoading = false;
        },
        onAdFailedToLoad: (error) {
          _rewardedLoading = false;
          Future.delayed(
            const Duration(seconds: 30),
            loadRewarded,
          );
        },
      ),
    );
  }

  bool get isRewardedReady => _rewarded != null;

  /// Shows a rewarded ad.
  /// [onRewarded] — called only when user earns the reward.
  /// [onComplete] — called after ad dismisses regardless of reward.
  /// [onNotReady] — called if no ad is available.
  void showRewarded({
    required VoidCallback onRewarded,
    VoidCallback? onComplete,
    VoidCallback? onNotReady,
  }) {
    if (_rewarded == null) {
      onNotReady?.call();
      return;
    }

    _rewarded!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewarded = null;
        loadRewarded();
        onComplete?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewarded = null;
        loadRewarded();
        onComplete?.call();
      },
    );

    _rewarded!.show(
      onUserEarnedReward: (ad, reward) => onRewarded(),
    );
  }

  // ── Init ──────────────────────────────────────────────────────────────────

  void preloadAll() {
    loadInterstitial();
    loadRewarded();
  }
}
