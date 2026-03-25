import 'package:flutter/material.dart';
import 'character_avatar.dart';

class Player {
  final int id;
  final String name;
  final Color? selectedColor;
  final CharacterAvatar? selectedCharacter;

  const Player({
    required this.id,
    this.name = '',
    this.selectedColor,
    this.selectedCharacter,
  });

  Player copyWith({
    int? id,
    String? name,
    Color? selectedColor,
    bool clearColor = false,
    CharacterAvatar? selectedCharacter,
    bool clearCharacter = false,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      selectedColor: clearColor ? null : (selectedColor ?? this.selectedColor),
      selectedCharacter: clearCharacter ? null : (selectedCharacter ?? this.selectedCharacter),
    );
  }
}