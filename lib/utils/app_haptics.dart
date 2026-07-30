import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Kendi projendeki ayarlar provider dosyanın yolunu buraya ekle
import '../utils/settings_provider.dart';

class AppHaptics {
  // 1. Hafif Tıklama (Butonlar, ileri/geri oyuncu geçişleri vs.)
  static void click(WidgetRef ref) {
    final isVibrationEnabled = ref.read(settingsProvider).vibrationEnabled;
    if (isVibrationEnabled) {
      HapticFeedback.selectionClick();
    }
  }

  // 2. Orta Vuruş (Paneli yukarı çekerken tık etmesi vs.)
  static void medium(WidgetRef ref) {
    final isVibrationEnabled = ref.read(settingsProvider).vibrationEnabled;
    if (isVibrationEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  // 3. Tok/Ağır Vuruş (Süre bittiğinde, oyun başladığında vs.)
  static void heavy(WidgetRef ref) {
    final isVibrationEnabled = ref.read(settingsProvider).vibrationEnabled;
    if (isVibrationEnabled) {
      HapticFeedback.heavyImpact();
    }
  }
}