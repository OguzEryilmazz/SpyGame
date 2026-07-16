import 'package:shared_preferences/shared_preferences.dart';

/// Ödüllü (rewarded) reklamlar arasında minimum bekleme süresi (cooldown)
/// uygular.
///
/// Amaç: Kullanıcıların art arda, saniyeler içinde onlarca reklam izleyip
/// AdMob'un "invalid traffic / kullanıcı davranışı" tespitlerine takılmasını,
/// hesabın kısıtlanmasını önlemek.
///
/// ÖNEMLİ: Artık GÜNLÜK bir üst sınır YOK. Kullanıcı istediği kadar reklam
/// izleyebilir; sadece iki reklam arasında [cooldown] süresi kadar
/// beklemesi gerekir. Bu sayede hem AdMob'un anormal/spam trafik tespiti
/// tetiklenmez hem de kullanıcı günlük bir kotaya takılmaz.
class AdWatchLimiter {
  AdWatchLimiter._();
  static final AdWatchLimiter instance = AdWatchLimiter._();

  static const _lastWatchKey = 'rewarded_ad_last_watch_ts';

  /// İki reklam izleme arasında geçmesi gereken minimum süre.
  /// İstersen bu değeri artırıp azaltabilirsin.
  static const Duration cooldown = Duration(seconds: 30);

  /// Bir sonraki reklamı izleyebilmek için kalan süreyi döner.
  /// Beklemeye gerek yoksa [Duration.zero] döner.
  Future<Duration> remainingCooldown() async {
    final prefs = await SharedPreferences.getInstance();
    final lastMs = prefs.getInt(_lastWatchKey);
    if (lastMs == null) return Duration.zero;

    final last = DateTime.fromMillisecondsSinceEpoch(lastMs);
    final elapsed = DateTime.now().difference(last);
    if (elapsed >= cooldown) return Duration.zero;
    return cooldown - elapsed;
  }

  /// Reklam şu an izlenebilir mi? (cooldown süresi dolmuş mu)
  Future<bool> canWatch() async {
    final remaining = await remainingCooldown();
    return remaining <= Duration.zero;
  }

  /// Bir reklam izleme hakkı kullanıldığında çağrılır
  /// (ödül kazanıldıktan / reklam gösterildikten sonra).
  Future<void> registerWatch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastWatchKey, DateTime.now().millisecondsSinceEpoch);
  }
}