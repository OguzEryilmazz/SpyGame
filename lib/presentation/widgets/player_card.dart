import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/logic/player_manager.dart';
import '../../domain/models/player.dart';

// ── Avatar helper ─────────────────────────────────────────────────────────────
// Kotlin's CharacterAvatar enum maps ordinal → R.drawable.pic_N.
// In Flutter we represent this as an index 0-8 → 'assets/images/pic_N.png'.

String avatarAsset(int index) => 'assets/images/pic_${index + 1}.png';

// ── PlayerCard ────────────────────────────────────────────────────────────────

/// Mirrors Kotlin PlayerSetUpComponents.kt → PlayerCard composable.
///
/// Shows:
///   • Coloured avatar circle (selected avatar image or person icon)
///   • "Oyuncu N" label
///   • Name text field
///   • Horizontal colour picker
///   • Horizontal avatar picker
class PlayerCard extends StatelessWidget {
  const PlayerCard({
    super.key,
    required this.player,
    required this.usedColorIndices,
    required this.usedAvatarIndices,
    required this.onNameChanged,
    required this.onColorSelected,
    required this.onAvatarSelected,
  });

  final Player player;

  /// Colour indices already taken by other players — greyed out.
  final Set<int> usedColorIndices;

  /// Avatar indices already taken by other players — greyed out.
  final Set<int> usedAvatarIndices;

  final ValueChanged<String> onNameChanged;
  final ValueChanged<int> onColorSelected;
  final ValueChanged<int> onAvatarSelected;

  @override
  Widget build(BuildContext context) {
    final playerColor =
        PlayerManager.availableColors[player.colorIndex % PlayerManager.availableColors.length];

    return Material(
      color: AppColors.cardSurface,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: avatar circle + label ───────────────────────────
          Row(
            children: [
              _AvatarCircle(
                color: playerColor,
                avatarIndex: player.avatarIndex,
              ),
              const SizedBox(width: 16),
              Text(
                'Oyuncu ${player.id}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Name input ──────────────────────────────────────────────
          _NameField(value: player.name, onChanged: onNameChanged),

          const SizedBox(height: 16),

          // ── Colour picker ───────────────────────────────────────────
          const _SectionLabel('Renk Seç:'),
          const SizedBox(height: 8),
          _ColorPicker(
            selectedIndex: player.colorIndex,
            usedIndices: usedColorIndices,
            playerColor: playerColor,
            onSelected: onColorSelected,
          ),

          const SizedBox(height: 16),

          // ── Avatar picker ───────────────────────────────────────────
          const _SectionLabel('Karakter Seç:'),
          const SizedBox(height: 8),
          _AvatarPicker(
            selectedIndex: player.avatarIndex,
            usedIndices: usedAvatarIndices,
            playerColor: playerColor,
            onSelected: onAvatarSelected,
          ),
        ],
      ),
    ),
    );
  }
}

// ── Avatar circle ─────────────────────────────────────────────────────────────

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.color, required this.avatarIndex});

  final Color color;
  final int avatarIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        avatarAsset(avatarIndex),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => const Icon(
          Icons.person,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

// ── Name field ────────────────────────────────────────────────────────────────

class _NameField extends StatelessWidget {
  const _NameField({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: value)
        ..selection = TextSelection.collapsed(offset: value.length),
      onChanged: onChanged,
      maxLength: 20,
      style: const TextStyle(color: AppColors.textPrimary),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        labelText: 'İsim',
        labelStyle: const TextStyle(color: AppColors.textMuted),
        counterText: '',
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: .5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
        filled: false,
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    );
  }
}

// ── Colour picker ─────────────────────────────────────────────────────────────

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({
    required this.selectedIndex,
    required this.usedIndices,
    required this.playerColor,
    required this.onSelected,
  });

  final int selectedIndex;
  final Set<int> usedIndices;
  final Color playerColor;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: PlayerManager.availableColors.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final color = PlayerManager.availableColors[i];
          final isSelected = i == selectedIndex;
          final isUsed = usedIndices.contains(i) && !isSelected;

          return GestureDetector(
            onTap: isUsed ? null : () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isUsed ? .3 : 1),
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: Colors.white, width: 3)
                    : null,
              ),
              // Show checkmark when selected
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
          );
        },
      ),
    );
  }
}

// ── Avatar picker ─────────────────────────────────────────────────────────────

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.selectedIndex,
    required this.usedIndices,
    required this.playerColor,
    required this.onSelected,
  });

  final int selectedIndex;
  final Set<int> usedIndices;
  final Color playerColor;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: PlayerManager.avatarCount,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isSelected = i == selectedIndex;
          final isUsed = usedIndices.contains(i) && !isSelected;

          return GestureDetector(
            onTap: isUsed ? null : () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : isUsed
                        ? Colors.white.withValues(alpha: .2)
                        : Colors.white.withValues(alpha: .4),
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: playerColor, width: 3)
                    : null,
              ),
              clipBehavior: Clip.antiAlias,
              child: Opacity(
                opacity: isUsed ? .35 : 1,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Image.asset(
                    avatarAsset(i),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
