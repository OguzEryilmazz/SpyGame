import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_ids.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  // Reklam yüklenemezse birkaç kez tekrar dene (özellikle uygulama/reklam
  // birimi yeni yayınlandıysa AdMob tarafında ilk saatlerde "no fill"
  // alınması normaldir).
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final ad = BannerAd(
      adUnitId: AdIds.banner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          _retryCount = 0;
          setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          // Hata kodunu görmek için: AdMob konsolunda "Ad units" raporunda
          // Requests > 0 ama Impressions = 0 ise bu genelde "no fill"
          // (yeni uygulama/reklam birimi ya da o bölgede talep yok) demektir.
          // error.code / error.domain / error.message alanları en çok
          // bilgi veren kısımdır.
          debugPrint(
            '[BannerAdWidget] Reklam yüklenemedi — '
            'code: ${error.code}, domain: ${error.domain}, '
            'message: ${error.message}',
          );
          if (_retryCount < _maxRetries && mounted) {
            _retryCount++;
            final delay = Duration(seconds: 15 * _retryCount);
            Future.delayed(delay, () {
              if (mounted) _loadAd();
            });
          }
        },
      ),
    );
    ad.load();
    _bannerAd = ad;
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) return const SizedBox.shrink();
    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
