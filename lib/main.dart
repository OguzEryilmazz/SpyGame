import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'router.dart';
import 'billing/iap_service.dart';
import 'ads/banner_ad_widget.dart';
import 'ads/ad_providers.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await IAPService().initialize();

  runApp(const ProviderScope(child: SpyApp()));
}

Future<void> requestTrackingAndInitAds() async {
  // DELAY
  await Future.delayed(const Duration(milliseconds: 500));

  final TrackingStatus status =
  await AppTrackingTransparency.trackingAuthorizationStatus;

  if (status == TrackingStatus.notDetermined) {
    await AppTrackingTransparency.requestTrackingAuthorization();
  }

  await _initConsent();
  await MobileAds.instance.initialize();
}

Future<void> _initConsent() async {
  final completer = Completer<void>();
  ConsentInformation.instance.requestConsentInfoUpdate(
    ConsentRequestParameters(),
        () async {
      if (await ConsentInformation.instance.isConsentFormAvailable()) {
        final innerCompleter = Completer<void>();
        ConsentForm.loadAndShowConsentFormIfRequired(
              (_) => innerCompleter.complete(),
        );
        await innerCompleter.future;
      }
      completer.complete();
    },
        (error) => completer.complete(),
  );
  return completer.future;
}

class SpyApp extends ConsumerStatefulWidget {
  const SpyApp({super.key});

  @override
  ConsumerState<SpyApp> createState() => _SpyAppState();
}

class _SpyAppState extends ConsumerState<SpyApp> {
  bool _adsReady = false;

  @override
  void initState() {
    super.initState();
    // Widget ağacı tamamen çizildikten sonra ATT + AdMob'u başlat.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await requestTrackingAndInitAds();
      if (mounted) {
        // SDK init + consent bittiği an reklamları önden yükle.
        // Provider'lar lazy olduğu için ilk ref.read burada loadAd()'ı tetikler.
        ref.read(interstitialAdProvider);
        ref.read(rewardedAdProvider);
        ref.read(rewardedInterstitialAdProvider);
        setState(() => _adsReady = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Spy - Haini Bul',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      routerConfig: appRouter,
      builder: (context, child) {
        return Column(
          children: [
            Expanded(child: child ?? const SizedBox.shrink()),
            if (_adsReady) const BannerAdWidget(),
          ],
        );
      },
    );
  }
}