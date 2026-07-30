import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final bool soundEnabled;
  final bool vibrationEnabled;

  SettingsState({
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      soundEnabled: prefs.getBool('soundEnabled') ?? true,
      vibrationEnabled: prefs.getBool('vibrationEnabled') ?? true,
    );
  }

  void toggleSound(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', value);
    state = SettingsState(
      soundEnabled: value,
      vibrationEnabled: state.vibrationEnabled,
    );
  }

  void toggleVibration(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibrationEnabled', value);
    state = SettingsState(
      soundEnabled: state.soundEnabled,
      vibrationEnabled: value,
    );
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});