enum CharacterAvatar {
  pic1,
  pic2,
  pic3,
  pic4,
  pic5,
  pic6,
  pic7,
  pic8,
  pic9;

  String get assetPath => 'assets/characters/${name.replaceAll('pic', 'pic_')}.png';
}