import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/setting_item.dart';
import '../widgets/counter_row.dart';

// State provider'lar
final playerCountProvider = StateProvider<int>((ref) => 4);
final gameDurationProvider = StateProvider<int>((ref) => 5);
final showHintsProvider = StateProvider<bool>((ref) => true);

class SetupScreen extends ConsumerWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerCount = ref.watch(playerCountProvider);
    final gameDuration = ref.watch(gameDurationProvider);
    final showHints = ref.watch(showHintsProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE91E63), // Pink
              Color(0xFF9C27B0), // Purple
              Color(0xFFF44336), // Red
            ],
          ),
        ),
        child: Stack(
          children: [
            // Scrollable content
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // Header
                  const Text(
                    'Spy - Haini Bul',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Oyun ayarlarını seç ve başla!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Settings Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        // Oyuncu Sayısı
                        SettingItem(
                          icon: Icons.people,
                          title: 'Oyuncu Sayısı',
                          subtitle: 'Kaç kişi oynayacak?',
                          iconColor: const Color(0xFFFF9800),
                          child: CounterRow(
                            value: playerCount,
                            onDecrease: () {
                              if (playerCount > 3) {
                                ref
                                    .read(playerCountProvider.notifier)
                                    .state--;
                              }
                            },
                            onIncrease: () {
                              if (playerCount < 9) {
                                ref
                                    .read(playerCountProvider.notifier)
                                    .state++;
                              }
                            },
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Oyun Süresi
                        SettingItem(
                          icon: Icons.access_time,
                          title: 'Oyun Süresi',
                          subtitle: 'Kaç dakika oynanacak?',
                          iconColor: const Color(0xFF2196F3),
                          child: CounterRow(
                            value: gameDuration,
                            onDecrease: () {
                              if (gameDuration > 1) {
                                ref
                                    .read(gameDurationProvider.notifier)
                                    .state--;
                              }
                            },
                            onIncrease: () {
                              if (gameDuration < 15) {
                                ref
                                    .read(gameDurationProvider.notifier)
                                    .state++;
                              }
                            },
                            suffix: ' dk',
                          ),
                        ),

                        const SizedBox(height: 32),

                        // İpucu Ayarı
                        SettingItem(
                          icon: showHints
                              ? Icons.visibility
                              : Icons.visibility_off,
                          title: 'Imposter İpucu',
                          subtitle: 'Imposter\'a ipucu gösterilsin mi?',
                          iconColor: showHints
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFF44336),
                          onIconClick: () {
                            ref.read(showHintsProvider.notifier).state =
                            !showHints;
                          },
                          child: const SizedBox.shrink(),
                        ),

                        // İpucu Açıklama Notu
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                            const Color(0xFF4CAF50).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info,
                                color: Color(0xFF4CAF50),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'İpuçlarını açtığınız takdirde Imposter\'a kategori hakkında ipucu verilecektir.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),

            // Bottom Button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push('/playerSetup/$playerCount');
                    },
                    icon: const Icon(
                      Icons.play_arrow,
                      color: Color(0xFFE91E63),
                      size: 20,
                    ),
                    label: const Text(
                      'Devam Et',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}