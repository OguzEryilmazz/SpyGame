import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';

void main() {
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
    );
  }
}