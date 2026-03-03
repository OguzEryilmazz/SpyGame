import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/logic/player_manager.dart';
import '../../providers/game_provider.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/player_card.dart';
import '../../widgets/spy_button.dart';

/// Mirrors Kotlin PlayerSetupScreen.kt.
///
/// Reads the player list from [gameStateProvider], delegates all mutations
/// to [GameNotifier]. Navigation is injected via [onBack] / [onNext] so the
/// screen stays decoupled from any routing package.
class PlayerSetupScreen extends ConsumerWidget {
  const PlayerSetupScreen({
    super.key,
    required this.onBack,
    required this.onNext,
  });

  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players = ref.watch(gameStateProvider.select((s) => s.players));
    final notifier = ref.read(gameStateProvider.notifier);
    final isValid = PlayerManager().isSetupValid(players);

    return GradientBackground(
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // ── Scrollable player list ──────────────────────────────────
            Column(
              children: [
                _TopBar(onBack: onBack),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                    itemCount: players.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final player = players[index];
                      // Indices used by every OTHER player
                      final usedColors = {
                        for (final p in players)
                          if (p.id != player.id) p.colorIndex,
                      };
                      final usedAvatars = {
                        for (final p in players)
                          if (p.id != player.id) p.avatarIndex,
                      };

                      return PlayerCard(
                        player: player,
                        usedColorIndices: usedColors,
                        usedAvatarIndices: usedAvatars,
                        onNameChanged: (name) => notifier.updatePlayer(
                          player.copyWith(name: name),
                        ),
                        onColorSelected: (colorIndex) =>
                            notifier.updatePlayer(
                          player.copyWith(colorIndex: colorIndex),
                        ),
                        onAvatarSelected: (avatarIndex) =>
                            notifier.updatePlayer(
                          player.copyWith(avatarIndex: avatarIndex),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // ── Fixed bottom button ─────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BottomBar(
                isValid: isValid,
                onNext: () {
                  notifier.goToCategorySelect();
                  onNext();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Row(
        children: [
          // Back button — mirrors Kotlin IconButton + ArrowBack
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.counterBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),

          const SizedBox(width: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Oyuncular',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'İsim, renk ve karakter seçin',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Bottom bar ────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.isValid, required this.onNext});

  final bool isValid;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.bottomScrim),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
        child: SpyButton(
          label: 'Kategori Seç',
          icon: Icons.play_arrow,
          onTap: isValid ? onNext : null,
          // Disabled state: grey foreground to mirror Kotlin's Color.Gray
          foregroundColor: isValid ? AppColors.pink : Colors.grey,
        ),
      ),
    );
  }
}
