import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/game_provider.dart';
import '../../widgets/counter_row.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/setting_item.dart';
import '../../widgets/spy_button.dart';

/// Mirrors Kotlin SetupScreen.kt — first screen of the game flow.
///
/// Reads / writes GameSettings through [gameStateProvider] (Riverpod Notifier).
/// Navigation is handled by passing [onNext] from the router — keeps the
/// screen decoupled from any specific navigation package.
class SetupScreen extends ConsumerWidget {
  const SetupScreen({super.key, required this.onNext});

  /// Called when the user taps "Devam Et".
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(gameStateProvider.select((s) => s.settings));
    final notifier = ref.read(gameStateProvider.notifier);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: Container(height: 50),
        body: SafeArea(
          child: Stack(
            children: [
              // ── Scrollable body ─────────────────────────────────────────
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── Header ─────────────────────────────────────────────
                    const Text(
                      'Spy - Haini Bul',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Oyun ayarlarını seç ve başla!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ── Settings card ──────────────────────────────────────
                    _SettingsCard(
                      settings: settings,
                      onPlayerCountDecrease: () =>
                          notifier.updatePlayerCount(settings.playerCount - 1),
                      onPlayerCountIncrease: () =>
                          notifier.updatePlayerCount(settings.playerCount + 1),
                      onDurationDecrease: () =>
                          notifier.updateDuration(settings.durationMinutes - 1),
                      onDurationIncrease: () =>
                          notifier.updateDuration(settings.durationMinutes + 1),
                      onHintsToggle: notifier.toggleHints,
                    ),
                  ],
                ),
              ),

              // ── Fixed bottom button ─────────────────────────────────────
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _BottomBar(
                  onNext: () {
                    notifier.goToPlayerSetup();
                    onNext();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Settings card ─────────────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.settings,
    required this.onPlayerCountDecrease,
    required this.onPlayerCountIncrease,
    required this.onDurationDecrease,
    required this.onDurationIncrease,
    required this.onHintsToggle,
  });

  final dynamic settings; // GameSettings
  final VoidCallback onPlayerCountDecrease;
  final VoidCallback onPlayerCountIncrease;
  final VoidCallback onDurationDecrease;
  final VoidCallback onDurationIncrease;
  final VoidCallback onHintsToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // ── Player count ─────────────────────────────────────────────
          SettingItem(
            icon: Icons.people,
            title: 'Oyuncu Sayısı',
            subtitle: 'Kaç kişi oynayacak?',
            iconColor: AppColors.orange,
            child: CounterRow(
              value: settings.playerCount,
              onDecrease: onPlayerCountDecrease,
              onIncrease: onPlayerCountIncrease,
              canDecrease: settings.playerCount > AppConstants.minPlayers,
              canIncrease: settings.playerCount < AppConstants.maxPlayers,
            ),
          ),

          const SizedBox(height: 32),

          // ── Game duration ─────────────────────────────────────────────
          SettingItem(
            icon: Icons.access_time,
            title: 'Oyun Süresi',
            subtitle: 'Kaç dakika oynanacak?',
            iconColor: AppColors.blue,
            child: CounterRow(
              value: settings.durationMinutes,
              onDecrease: onDurationDecrease,
              onIncrease: onDurationIncrease,
              suffix: ' dk',
              canDecrease:
                  settings.durationMinutes > AppConstants.minDurationMinutes,
              canIncrease:
                  settings.durationMinutes < AppConstants.maxDurationMinutes,
            ),
          ),

          const SizedBox(height: 32),

          // ── Hints toggle ──────────────────────────────────────────────
          SettingItem(
            icon: settings.hintsEnabled
                ? Icons.visibility
                : Icons.visibility_off,
            title: 'Imposter İpucu',
            subtitle: 'Imposter\'a ipucu gösterilsin mi?',
            iconColor: settings.hintsEnabled ? AppColors.green : AppColors.red,
            onIconTap: onHintsToggle,
          ),

          const SizedBox(height: 12),

          // ── Hints info card ───────────────────────────────────────────
          _HintInfoCard(visible: settings.hintsEnabled),
        ],
      ),
    );
  }
}

// ── Hint info card ────────────────────────────────────────────────────────────

class _HintInfoCard extends StatelessWidget {
  const _HintInfoCard({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: visible
          ? Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.hintCardBg,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: AppColors.green, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'İpuçlarını açtığınız takdirde Imposter\'a '
                      'kategori hakkında ipucu verilecektir.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

// ── Bottom bar ────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: SpyButton(
        label: 'Devam Et',
        icon: Icons.play_arrow,
        onTap: onNext,
      ),
    );
  }
}
