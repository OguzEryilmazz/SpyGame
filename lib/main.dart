import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'router.dart';
import 'billing/iap_service.dart';
import 'ads/banner_ad_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  await IAPService().initialize();
  runApp(
    const ProviderScope(
      child: SpyApp(),
    ),
  );
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
        return Scaffold(
          body: child ?? const SizedBox.shrink(),
          bottomNavigationBar: const BannerAdWidget(),
        );
      },
    );
  }
}