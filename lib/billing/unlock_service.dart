import 'package:shared_preferences/shared_preferences.dart';
import 'iap_products.dart';

class UnlockService {
  static const _prefix = 'unlocked_';

  // Satın alındığında kaydet
  static Future<void> unlock(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix$productId', true);
  }

  // Kilitli mi kontrol et
  static Future<bool> isUnlocked(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_prefix$productId') ?? false;
  }

  // Kategori açık mı? (ana kategori VEYA alt kategori satın alınmış)
  static Future<bool> isCategoryUnlocked(String categoryId) async {
    // Üst kategori satın alınmışsa direkt açık
    final parentId = IAPProducts.productIdForCategory(categoryId);
    if (parentId != null && await isUnlocked(parentId)) return true;

    // Alt kategori ise kendi ID'sine bak
    final subId = IAPProducts.productIdForSubcategory(categoryId);
    if (subId != null && await isUnlocked(subId)) return true;

    return false;
  }
}