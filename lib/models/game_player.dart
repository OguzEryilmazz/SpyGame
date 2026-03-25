import 'package:flutter/material.dart';
import 'character_avatar.dart';

class GamePlayer {
  final int id;
  final String name;
  final Color? selectedColor;
  final CharacterAvatar? selectedCharacter;
  final bool isSpy;
  final String assignedWord;
  final String? hint;

  const GamePlayer({
    required this.id,
    required this.name,
    this.selectedColor,
    this.selectedCharacter,
    required this.isSpy,
    required this.assignedWord,
    this.hint, required  color, required String role,
  });
}