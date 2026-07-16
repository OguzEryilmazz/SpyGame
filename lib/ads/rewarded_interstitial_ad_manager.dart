import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_ids.dart';

/// "Rewarded Interstitial" reklamlarını yönetir.
///
/// Bu, standart ödüllü (rewarded) reklamdan FARKLIDIR:
/// - Kullanıcı "izle" butonuna basmaz — ekranlar arası doğal bir geçişte
///   (ör. oylama bitip sonuç ekranına geçerken) OTOMATİK gösterilir.
/// - Buna karşılık AdMob politikası, reklam patlamadan önce ödülü
///   açıklayan ve "atla" seçeneği sunan kısa bir tanıtım ekranı
///   göstermeyi ZORUNLU kılıyor (aksi halde politika ihlali sayılır).
///
/// [maybeShowBeforeReveal] hem bu tanıtım ekranını hem frekans kontrolünü
/// (her seferinde değil, ara sıra göstermek için) kendi içinde halleder.
/// Reklam gösterilmese de gösterilse de sonunda mutlaka [onComplete]
/// çağrılır — kullanıcı asla takılı kalmaz.
class RewardedInterstitialAdManager {
  RewardedInterstitialAd? _ad;
  bool _isLoading = false;

  int _triggerCount = 0;

  /// Kaç geçişten birinde reklam gösterilsin.
  /// 3 => her 3 sonuç ekranından 1'inde gösterilir.
  /// AdMob'da spam/invalid-traffic riskini azaltmak ve kullanıcı
  /// deneyimini bozmamak için "her seferinde" DEĞİL, ara sıra gösteriyoruz.
  static const int _showEveryNth = 3;

  void loadAd() {
    if (_isLoading || _ad != null) return;
    _isLoading = true;

    RewardedInterstitialAd.load(
      adUnitId: AdIds.rewardedInterstitial,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          _ad = null;
          _isLoading = false;
        },
      ),
    );
  }

  bool get isAdReady => _ad != null;

  /// Sonucu göstermeden hemen önce çağır.
  /// Frekans kontrolüne takılırsa, reklam hazır değilse veya kullanıcı
  /// "atla" derse — direkt [onComplete] çağrılır, kullanıcı bekletilmez.
  Future<void> maybeShowBeforeReveal({
    required BuildContext context,
    required VoidCallback onComplete,
  }) async {
    _triggerCount++;
    final selectedThisTime = _triggerCount % _showEveryNth == 0;

    if (!selectedThisTime || _ad == null) {
      onComplete();
      return;
    }

    if (!context.mounted) {
      onComplete();
      return;
    }

    // ── AdMob'un zorunlu kıldığı tanıtım ekranı ──
    // Reklam otomatik oynamadan önce kullanıcıya ne olacağını anlatıp
    // atlama seçeneği sunuyoruz.
    final wantsToWatch = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a1625),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sonuçlar hazırlanıyor',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Kısa bir reklamın ardından Spy kimmiş göreceksin.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Atla', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Devam Et',
                style: TextStyle(color: Colors.greenAccent)),
          ),
        ],
      ),
    );

    if (wantsToWatch != true || _ad == null) {
      onComplete();
      return;
    }

    final ad = _ad!;
    _ad = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        onComplete();
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        onComplete();
        loadAd();
      },
    );

    ad.show(
      onUserEarnedReward: (ad, reward) {
        // Şu an ödüle bağlı özel bir bonus yok, reklam formatı bunu
        // gerektiriyor. İstersen ileride buraya (ör. ekstra ipucu,
        // sonuç ekranında özel bir rozet vb.) bağlayabiliriz.
      },
    );
  }

  void dispose() {
    _ad?.dispose();
    _ad = null;
  }
}