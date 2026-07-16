import 'package:shared_preferences/shared_preferences.dart';

/// Ödüllü (rewarded) reklamların günlük izlenme sayısını sınırlar.
///
/// Amaç: Kullanıcıların art arda onlarca reklam izleyip AdMob'un
/// "invalid traffic / kullanıcı davranışı" tespitlerine takılmasını,
/// hesabın kısıtlanmasını önlemek. Sayaç her gün UTC gece yarısında
/// otomatik sıfırlanır (cihaz tarihine göre).
class AdWatchLimiter {
  AdWatchLimiter._();
  static final AdWatchLimiter instance = AdWatchLimiter._();

  static const _countKey = 'rewarded_ad_watch_count';
  static const _dateKey = 'rewarded_ad_watch_date';

  /// Günlük izin verilen maksimum ödüllü reklam sayısı.
  /// İstersen bu değeri artırıp azaltabilirsin.
  static const int dailyLimit = 5;

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  Future<int> _currentCount(SharedPreferences prefs) async {
    final savedDate = prefs.getString(_dateKey);
    if (savedDate != _todayKey()) {
      // Yeni gün: sayaç sıfırlanır.
      await prefs.setString(_dateKey, _todayKey());
      await prefs.setInt(_countKey, 0);
      return 0;
    }
    return prefs.getInt(_countKey) ?? 0;
  }

  /// Kalan hak sayısını döner (0 ise limit dolmuş demektir).
  Future<int> remaining() async {
    final prefs = await SharedPreferences.getInstance();
    final count = await _currentCount(prefs);
    final left = dailyLimit - count;
    return left < 0 ? 0 : left;
  }

  /// Reklam izlenebilir mi?
  Future<bool> canWatch() async {
    final left = await remaining();
    return left > 0;
  }

  /// Bir reklam izleme hakkı kullanıldığında çağrılır
  /// (ödül kazanıldıktan / reklam gösterildikten sonra).
  Future<void> registerWatch() async {
    final prefs = await SharedPreferences.getInstance();
    final count = await _currentCount(prefs);
    await prefs.setInt(_countKey, count + 1);
  }
}
