import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'screens/setup_screen.dart';
import 'screens/player_setup_screen.dart';
import 'screens/category_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SetupScreen(),
    ),
    GoRoute(
      path: '/playerSetup/:playerCount',
      builder: (context, state) {
        final playerCount = int.tryParse(
          state.pathParameters['playerCount'] ?? '4',
        ) ?? 4;
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
  ],
);