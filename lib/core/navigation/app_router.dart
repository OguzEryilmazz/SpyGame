import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/game_state.dart';
import '../../presentation/providers/game_provider.dart';
import '../../presentation/screens/category/category_screen.dart';
import '../../presentation/screens/game/game_reveal_screen.dart';
import '../../presentation/screens/player_setup/player_setup_screen.dart';
import '../../presentation/screens/setup/setup_screen.dart';
import '../../presentation/screens/timer/timer_screen.dart';
import '../../presentation/screens/voting/voting_screen.dart';
import '../ads/ad_manager.dart';
import '../constants/app_constants.dart';

// ── Phase ordering (used to decide slide direction) ───────────────────────────

const _phaseOrder = [
  GamePhase.setup,
  GamePhase.playerSetup,
  GamePhase.categorySelect,
  GamePhase.roleReveal,
  GamePhase.timer,
  GamePhase.voting,
  GamePhase.results,
];

int _orderOf(GamePhase p) => _phaseOrder.indexOf(p);

// ── Phase → path mapping ──────────────────────────────────────────────────────

String _pathFor(GamePhase phase) => switch (phase) {
      GamePhase.setup => AppConstants.routeSetup,
      GamePhase.playerSetup => AppConstants.routePlayerSetup,
      GamePhase.categorySelect => AppConstants.routeCategory,
      GamePhase.roleReveal => AppConstants.routeGame,
      GamePhase.timer => AppConstants.routeTimer,
      GamePhase.voting || GamePhase.results => AppConstants.routeVoting,
    };

// ── ProviderScope listenable bridge ──────────────────────────────────────────

class _PhaseNotifier extends ChangeNotifier {
  _PhaseNotifier(this._ref) {
    _current = _ref.read(gameStateProvider).phase;
    _previous = _current;
    _ref.listen<GamePhase>(
      gameStateProvider.select((s) => s.phase),
      (prev, next) {
        _previous = prev ?? _current;
        _current = next;
        notifyListeners();
      },
    );
  }

  final Ref _ref;
  late GamePhase _current;
  late GamePhase _previous;

  bool get isGoingBack => _orderOf(_current) < _orderOf(_previous);
}

// ── Router provider ───────────────────────────────────────────────────────────

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _PhaseNotifier(ref);

  final router = GoRouter(
    initialLocation: AppConstants.routeSetup,
    refreshListenable: notifier,
    redirect: (context, state) {
      final phase = ref.read(gameStateProvider).phase;
      final intended = _pathFor(phase);
      if (state.uri.path != intended) return intended;
      return null;
    },
    routes: [
      // ── Setup ─────────────────────────────────────────────────────────────
      GoRoute(
        path: AppConstants.routeSetup,
        pageBuilder: (context, state) => _slide(
          state,
          notifier,
          Consumer(
            builder: (context, ref, _) => SetupScreen(
              onNext: () =>
                  ref.read(gameStateProvider.notifier).goToPlayerSetup(),
            ),
          ),
        ),
      ),

      // ── Player Setup ───────────────────────────────────────────────────────
      GoRoute(
        path: AppConstants.routePlayerSetup,
        pageBuilder: (context, state) => _slide(
          state,
          notifier,
          Consumer(
            builder: (context, ref, _) => PlayerSetupScreen(
              onBack: () =>
                  ref.read(gameStateProvider.notifier).goBackToSetup(),
              onNext: () =>
                  ref.read(gameStateProvider.notifier).goToCategorySelect(),
            ),
          ),
        ),
      ),

      // ── Category Select ────────────────────────────────────────────────────
      GoRoute(
        path: AppConstants.routeCategory,
        pageBuilder: (context, state) => _slide(
          state,
          notifier,
          Consumer(
            builder: (context, ref, _) => CategoryScreen(
              onBack: () =>
                  ref.read(gameStateProvider.notifier).goBackToPlayerSetup(),
              onNext: () {},
            ),
          ),
        ),
      ),

      // ── Role Reveal ────────────────────────────────────────────────────────
      GoRoute(
        path: AppConstants.routeGame,
        pageBuilder: (context, state) => _noTransition(
          state,
          Consumer(
            builder: (context, ref, _) => GameRevealScreen(
              onBack: () =>
                  ref.read(gameStateProvider.notifier).goBackToCategorySelect(),
              onNext: () {},
            ),
          ),
        ),
      ),

      // ── Timer ──────────────────────────────────────────────────────────────
      GoRoute(
        path: AppConstants.routeTimer,
        pageBuilder: (context, state) => _slide(
          state,
          notifier,
          Consumer(
            builder: (context, ref, _) => TimerScreen(
              onBack: () =>
                  ref.read(gameStateProvider.notifier).goBackToSetup(),
              onNext: () =>
                  ref.read(gameStateProvider.notifier).goToVoting(),
            ),
          ),
        ),
      ),

      // ── Voting + Results ───────────────────────────────────────────────────
      GoRoute(
        path: AppConstants.routeVoting,
        pageBuilder: (context, state) => _slide(
          state,
          notifier,
          Consumer(
            builder: (context, ref, _) => VotingScreen(
              onBack: () =>
                  ref.read(gameStateProvider.notifier).goBackToSetup(),
              onPlayAgain: () =>
                  AdManager.instance.showInterstitialWithCallback(
                    () => ref.read(gameStateProvider.notifier).resetGame(),
                  ),
              onMainMenu: () =>
                  AdManager.instance.showInterstitialWithCallback(
                    () => ref.read(gameStateProvider.notifier).resetGame(),
                  ),
            ),
          ),
        ),
      ),
    ],

    // ── 404 fallback ───────────────────────────────────────────────────────────
    errorPageBuilder: (context, state) => MaterialPage(
      child: Scaffold(
        body: Center(
          child: Text(
            'Sayfa bulunamadı: ${state.uri}',
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    ),
  );

  ref.onDispose(() {
    notifier.dispose();
    router.dispose();
  });

  return router;
});

// ── Page transition helpers ───────────────────────────────────────────────────

CustomTransitionPage<void> _slide(
  GoRouterState state,
  _PhaseNotifier notifier,
  Widget child,
) {
  final goingBack = notifier.isGoingBack;
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final enterTween = Tween(
        begin: Offset(goingBack ? -1.0 : 1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOutCubic));

      return SlideTransition(
        position: animation.drive(enterTween),
        child: child,
      );
    },
  );
}

CustomTransitionPage<void> _noTransition(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        child,
  );
}
