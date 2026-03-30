import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:spy_app/billing/unlock_service.dart';

class IAPService {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;

  // Ürün ID'lerini buraya ekle
  static const Set<String> _productIds = {
    'com.yourapp.premium',
  };

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> products = [];
  bool isAvailable = false;

  // Satın alınan ürünleri takip et
  final Set<String> _purchasedProductIds = {};

  /// Servisi başlat
  Future<void> initialize() async {
    isAvailable = await _iap.isAvailable();
    if (!isAvailable) return;

    // Satın alma stream'ini dinle
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onError: (error) => print('IAP stream error: $error'),
    );

    await _loadProducts();
    await _restorePurchases(); // Uygulama açılışında restore et
  }

  /// Ürünleri App Store'dan yükle
  Future<void> _loadProducts() async {
    final response = await _iap.queryProductDetails(_productIds);

    if (response.error != null) {
      print('Ürün yükleme hatası: ${response.error}');
      return;
    }

    products = response.productDetails;
  }

  /// Satın alma başlat
  Future<void> buyProduct(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// Satın almaları geri yükle
  Future<void> _restorePurchases() async {
    await _iap.restorePurchases();
  }

  Future<void> restorePurchases() async {
    await _restorePurchases();
  }

  /// Satın alma durumunu işle
  Future<void> _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          print('Satın alma bekleniyor: ${purchase.productID}');
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
        // ✅ Başarılı — sunucunda doğrula (production'da önerilir)
          _deliverProduct(purchase);
          await _iap.completePurchase(purchase);
          break;

        case PurchaseStatus.error:
          print('Satın alma hatası: ${purchase.error}');
          await _iap.completePurchase(purchase);
          break;

        case PurchaseStatus.canceled:
          print('Satın alma iptal edildi');
          break;
      }
    }
  }

  /// Ürünü kullanıcıya teslim et
  void _deliverProduct(PurchaseDetails purchase) async {
    await UnlockService.unlock(purchase.productID);
    print('Ürün teslim edildi ve kaydedildi: ${purchase.productID}');
    // Provider/Riverpod/BLoC ile state güncellemesi yapabilirsiniz
  }

  /// Ürün satın alınmış mı kontrol et
  bool isPurchased(String productId) {
    return _purchasedProductIds.contains(productId);
  }

  /// Temizlik
  void dispose() {
    _subscription?.cancel();
  }
}