import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/setup_screen.dart';
import 'screens/player_setup_screen.dart';
import 'screens/category_screen.dart';
import 'screens/game_screen.dart';
import 'screens/tutorial_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/tutorial',
  redirect: (context, state) async {
    if (state.matchedLocation != '/tutorial') return null;

    final prefs = await SharedPreferences.getInstance();
    final showEvery10 = prefs.getBool('show_every_10') ?? false;

    if (!showEvery10) return null;

    final counter = prefs.getInt('tutorial_counter_for_interval') ?? 0;
    final newCounter = counter + 1;
    await prefs.setInt('tutorial_counter_for_interval', newCounter);

    if (newCounter < 10) return '/';
    await prefs.setInt('tutorial_counter_for_interval', 0);
    return null;
  },
  routes: [
    GoRoute(
      path: '/tutorial',
      builder: (context, state) => const TutorialScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const SetupScreen(),
    ),
    GoRoute(
      path: '/playerSetup/:playerCount',
      builder: (context, state) {
        final playerCount = int.tryParse(
          state.pathParameters['playerCount'] ?? '4',
        ) ??
            4;
        return PlayerSetupScreen(playerCount: playerCount);
      },
    ),
    GoRoute(
      path: '/categoryScreen',
      builder: (ctx, state) {
        return Consumer(
          builder: (context, ref, _) {
            final players = ref.watch(playersProvider);
            return CategoryScreen(players: players);
          },
        );
      },
    ),
    GoRoute(
      path: '/game',
      builder: (context, state) => const GameScreen(),
    ),
  ],
);