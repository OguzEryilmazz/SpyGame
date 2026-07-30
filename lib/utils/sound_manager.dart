import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final AudioPlayer _tickPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  // Son 10 saniyede her saniye çalacak tik-tak sesi
  Future<void> playTick() async {
    await _tickPlayer.play(AssetSource('sounds/tick.mp3'), volume: 0.6);
  }

  // Animasyon dolduğunda ve oyun bittiğinde çalacak vurucu ses
  Future<void> playBoom() async {
    await _sfxPlayer.play(AssetSource('sounds/boom.mp3'), volume: 1.0);
  }
}