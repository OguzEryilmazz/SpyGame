import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_ids.dart';

class RewardedAdManager {
  RewardedAd? _rewardedAd;
  bool _isLoading = false;

  void loadAd({
    Function()? onAdLoaded,
    Function(String)? onAdFailedToLoad,
  }) {
    if (_isLoading) return;
    _isLoading = true;

    RewardedAd.load(
      adUnitId: AdIds.rewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoading = false;
          onAdLoaded?.call();
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isLoading = false;
          onAdFailedToLoad?.call(error.message);
        },
      ),
    );
  }

  void showAd({
    required Function(int amount, String type) onUserEarnedReward,
    Function()? onAdDismissed,
    Function(String)? onAdShowFailed,
  }) {
    if (_rewardedAd == null) {
      onAdShowFailed?.call('Reklam henüz yüklenmedi');
      loadAd();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        onAdDismissed?.call();
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        onAdShowFailed?.call(error.message);
        loadAd();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onUserEarnedReward(reward.amount.toInt(), reward.type);
      },
    );
  }

  bool get isAdReady => _rewardedAd != null;

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
