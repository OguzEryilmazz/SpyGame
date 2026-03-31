import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_ids.dart';

class InterstitialAdManager {
  InterstitialAd? _interstitialAd;
  bool _isLoading = false;
  int _showCount = 0;
  static const int _showEveryNth = 2;

  void loadAd() {
    if (_isLoading || _interstitialAd != null) return;
    _isLoading = true;

    InterstitialAd.load(
      adUnitId: AdIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isLoading = false;
        },
      ),
    );
  }

  void showAdWithFrequencyControl({
    required Function() onAdDismissed,
  }) {
    _showCount++;
    if (_showCount % _showEveryNth != 0) {
      onAdDismissed();
      return;
    }
    showAd(onAdDismissed: onAdDismissed);
  }

  void showAd({required Function() onAdDismissed}) {
    if (_interstitialAd == null) {
      loadAd();
      onAdDismissed();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        onAdDismissed();
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        onAdDismissed();
        loadAd();
      },
    );

    _interstitialAd!.show();
  }

  bool get isAdReady => _interstitialAd != null;

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
