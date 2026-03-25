import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/character_avatar.dart';

class PlayerCard extends StatefulWidget {
  final Player player;
  final List<Color> availableColors;
  final List<Color> usedColors;
  final List<CharacterAvatar> usedCharacters;
  final ValueChanged<String> onNameChange;
  final ValueChanged<Color?> onColorChange;
  final ValueChanged<CharacterAvatar?> onCharacterChange;

  const PlayerCard({
    super.key,
    required this.player,
    required this.availableColors,
    required this.usedColors,
    required this.usedCharacters,
    required this.onNameChange,
    required this.onColorChange,
    required this.onCharacterChange,
  });

  @override
  State<PlayerCard> createState() => _PlayerCardState();
}

class _PlayerCardState extends State<PlayerCard> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.player.name);
  }

  @override
  void didUpdateWidget(PlayerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Dışarıdan isim değiştiyse (örn. farklı oyuncu sayısı) güncelle
    if (oldWidget.player.name != widget.player.name &&
        _nameController.text != widget.player.name) {
      _nameController.text = widget.player.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.player;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: player.selectedColor ?? Colors.grey,
                child: player.selectedCharacter != null
                    ? ClipOval(
                  child: Image.asset(
                    player.selectedCharacter!.assetPath,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                )
                    : const Icon(Icons.person, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                'Oyuncu ${player.id}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // İsim
          TextField(
            controller: _nameController,
            onChanged: widget.onNameChange,
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              labelText: 'İsim',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Renk seçimi
          const Text('Renk Seç:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.availableColors.map((color) {
                final isSelected = player.selectedColor == color;
                final isUsed = widget.usedColors.contains(color);
                final isClickable = !isUsed || isSelected;

                return GestureDetector(
                  onTap: isClickable
                      ? () {
                    if (isSelected) {
                      widget.onColorChange(null);
                    } else if (!isUsed) {
                      widget.onColorChange(color);
                    }
                  }
                      : null,
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withOpacity(isUsed && !isSelected ? 0.3 : 1.0),
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                    ),
                    child: isUsed && !isSelected
                        ? const Icon(Icons.close, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Karakter seçimi
          const Text('Karakter Seç:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: CharacterAvatar.values.map((character) {
                final isSelected = player.selectedCharacter == character;
                final isUsed = widget.usedCharacters.contains(character);

                return GestureDetector(
                  onTap: () {
                    if (isSelected) {
                      widget.onCharacterChange(null);
                    } else if (!isUsed) {
                      widget.onCharacterChange(character);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? Colors.white
                          : isUsed
                          ? Colors.grey.withOpacity(0.4)
                          : Colors.white.withOpacity(0.4),
                      border: isSelected
                          ? Border.all(color: player.selectedColor ?? Colors.grey, width: 3)
                          : null,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipOval(
                          child: Opacity(
                            opacity: isUsed && !isSelected ? 0.3 : 1.0,
                            child: Image.asset(
                              character.assetPath,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        if (isUsed && !isSelected)
                          const Icon(Icons.close, color: Colors.red, size: 20),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}