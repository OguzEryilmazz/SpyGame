import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'router.dart';
import 'billing/iap_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppTrackingTransparency.requestTrackingAuthorization();

  await _initConsent();

  await MobileAds.instance.initialize();
  await IAPService().initialize();
  runApp(
    const ProviderScope(
      child: SpyApp(),
    ),
  );
}

Future<void> _initConsent() async {
  final completer = Completer<void>();
  ConsentInformation.instance.requestConsentInfoUpdate(
    ConsentRequestParameters(),
    () async {
      if (await ConsentInformation.instance.isConsentFormAvailable()) {
        final innerCompleter = Completer<void>();
        ConsentForm.loadAndShowConsentFormIfRequired((_) => innerCompleter.complete());
        await innerCompleter.future;
      }
      completer.complete();
    },
    (error) => completer.complete(),
  );
  return completer.future;
}

class SpyApp extends ConsumerWidget {
  const SpyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Spy - Haini Bul',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      builder: (context, child) {
        return Column(
          children: [
            Expanded(child: child ?? const SizedBox.shrink()),
            // const BannerAdWidget(),
          ],
        );
      },
    );
  }
}
