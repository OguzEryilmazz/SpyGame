class AppConstants {
  AppConstants._();

  // ── Game rules (mirrors Kotlin GameEngine.validateGameSetup) ─────────────
  static const int minPlayers = 3;
  static const int maxPlayers = 9;
  static const int defaultPlayerCount = 4;

  static const int minDurationMinutes = 1;
  static const int maxDurationMinutes = 15;
  static const int defaultDurationMinutes = 5;

  // ── Navigation route names ────────────────────────────────────────────────
  static const String routeSetup = '/';
  static const String routePlayerSetup = '/player-setup';
  static const String routeCategory = '/category';
  static const String routeGame = '/game';
  static const String routeTimer = '/timer';
  static const String routeVoting = '/voting';
  static const String routeResults = '/results';
  static const String routeTutorial = '/tutorial';
}
