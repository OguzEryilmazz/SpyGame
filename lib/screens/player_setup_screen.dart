import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/player.dart';
import '../models/character_avatar.dart';
import '../widgets/player_card.dart';

final playersProvider = StateProvider<List<Player>>((ref) => []);

class PlayerSetupScreen extends ConsumerStatefulWidget {
  final int playerCount;
  final List<Player> existingPlayers;

  const PlayerSetupScreen({
    super.key,
    required this.playerCount,
    this.existingPlayers = const [],
  });

  @override
  ConsumerState<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends ConsumerState<PlayerSetupScreen> {
  final List<Color> availableColors = const [
    Color(0xFFE91E63), Color(0xFF9C27B0), Color(0xFF3F51B5),
    Color(0xFF2196F3), Color(0xFF00BCD4), Color(0xFF4CAF50),
    Color(0xFF8BC34A), Color(0xFFFFEB3B), Color(0xFFFF9800),
    Color(0xFFFF5722), Color(0xFF795548), Color(0xFF607D8B),
  ];

  late List<Player> players;

  @override
  void initState() {
    super.initState();
    _initPlayers();
  }

  void _initPlayers() {
    final existing = widget.existingPlayers;
    final count = widget.playerCount;

    if (existing.length >= count) {
      players = existing.take(count).mapIndexed((i, p) => p.copyWith(id: i + 1)).toList();
    } else {
      final result = <Player>[];
      for (int i = 0; i < existing.length; i++) {
        result.add(existing[i].copyWith(id: i + 1));
      }
      for (int i = existing.length; i < count; i++) {
        result.add(Player(id: i + 1, name: 'Oyuncu ${i + 1}'));
      }
      players = result;
    }
  }

  bool get isFormValid => players.every((p) => p.name.trim().isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE91E63),
              Color(0xFF9C27B0),
              Color(0xFFF44336),
            ],
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 20),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Oyuncular',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'İsim, renk ve karakter seçin',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Liste
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: players.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final player = players[index];
                      return PlayerCard(
                        player: player,
                        availableColors: availableColors,
                        usedColors: players
                            .where((p) => p.id != player.id)
                            .map((p) => p.selectedColor)
                            .whereType<Color>()
                            .toList(),
                        usedCharacters: players
                            .where((p) => p.id != player.id)
                            .map((p) => p.selectedCharacter)
                            .whereType<CharacterAvatar>()
                            .toList(),
                        onNameChange: (name) => setState(() {
                          players = players
                              .map((p) => p.id == player.id ? p.copyWith(name: name) : p)
                              .toList();
                        }),
                        onColorChange: (color) => setState(() {
                          players = players
                              .map((p) => p.id == player.id
                              ? p.copyWith(
                            selectedColor: color,
                            clearColor: color == null,
                          )
                              : p)
                              .toList();
                        }),
                        onCharacterChange: (char) => setState(() {
                          players = players
                              .map((p) => p.id == player.id
                              ? p.copyWith(
                            selectedCharacter: char,
                            clearCharacter: char == null,
                          )
                              : p)
                              .toList();
                        }),
                      );
                    },
                  ),
                ),
              ],
            ),

            // Bottom button
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
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: isFormValid
                        ? () {
                      ref.read(playersProvider.notifier).state = players;
                      context.push('/categoryScreen');
                    }
                        : null,
                    icon: Icon(
                      Icons.play_arrow,
                      color: isFormValid ? const Color(0xFFE91E63) : Colors.grey,
                    ),
                    label: Text(
                      'Kategori Seç',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isFormValid ? const Color(0xFFE91E63) : Colors.grey,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      disabledBackgroundColor: Colors.white.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
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

// Dart'ta mapIndexed extension
extension IndexedIterable<E> on Iterable<E> {
  List<T> mapIndexed<T>(T Function(int index, E element) f) {
    var i = 0;
    return map((e) => f(i++, e)).toList();
  }
}