import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── SharedPreferences keys ────────────────────────────────────────────────────

class _BillingKeys {
  static const String purchasedCategories = 'purchased_categories';
  static const String purchasedSubcategories = 'purchased_subcategories';
  static const String singleUseUnlocked = 'single_use_unlocked_subcategories';
}

// ── Product ID sets ───────────────────────────────────────────────────────────

class ProductIds {
  ProductIds._();

  static const Set<String> categories = {
    'animals',
    'singers',
    'sports',
    'countries',
    'actors',
    'streamers',
    'youtubers',
  };

  static const Set<String> subcategories = {
    'athletes_active_football_domestic',
    'athletes_active_football_foreign',
    'athletes_retired_football_domestic',
    'athletes_retired_football_foreign',
    'athletes_basketball_nba',
    'athletes_basketball_euroleague',
    'athletes_basketball_legends',
    'athletes_volleyball_female',
    'athletes_ufc',
    'athletes_wwe',
    'athletes_boxing',
    'athletes_f1',
    'actors_foreign_male',
    'actors_foreign_female',
  };

  static Set<String> get all => {...categories, ...subcategories};
}

// ── Purchase result sealed class ──────────────────────────────────────────────

sealed class PurchaseResult {
  const PurchaseResult();
}

class PurchaseSuccess extends PurchaseResult {
  final String productId;
  const PurchaseSuccess(this.productId);
}

class PurchasePending extends PurchaseResult {
  const PurchasePending();
}

class PurchaseError extends PurchaseResult {
  final String message;
  const PurchaseError(this.message);
}

class PurchaseCancelled extends PurchaseResult {
  const PurchaseCancelled();
}

// ── BillingManager ────────────────────────────────────────────────────────────

/// Manages in-app purchases for both iOS (StoreKit) and Android (Billing Library)
/// via the in_app_purchase package.
///
/// Initialize once at app start:
///   await BillingManager.instance.initialize();
class BillingManager {
  BillingManager._();
  static final BillingManager instance = BillingManager._();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  final _purchaseController = StreamController<PurchaseResult>.broadcast();
  Stream<PurchaseResult> get purchaseStream => _purchaseController.stream;

  Set<String> _purchasedCategories = {};
  Set<String> _purchasedSubcategories = {};
  Set<String> _singleUseUnlocked = {};
  Map<String, ProductDetails> _products = {};
  bool _storeAvailable = false;

  // ── Public read-only accessors ────────────────────────────────────────────

  Set<String> get allPurchasedIds => {
        ..._purchasedCategories,
        ..._purchasedSubcategories,
      };

  Set<String> get singleUseUnlockedIds => Set.unmodifiable(_singleUseUnlocked);

  bool isCategoryPurchased(String id) => _purchasedCategories.contains(id);

  bool isSubcategoryPurchased(String id) =>
      _purchasedSubcategories.contains(id);

  bool isSubcategorySingleUseUnlocked(String id) =>
      _singleUseUnlocked.contains(id);

  /// Returns the store-formatted price string (e.g. "₺25,99") or null.
  String? getPriceString(String productId) => _products[productId]?.price;

  // ── Initialization ────────────────────────────────────────────────────────

  Future<void> initialize() async {
    await _loadPersistedPurchases();

    _storeAvailable = await _iap.isAvailable();
    if (!_storeAvailable) return;

    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (Object error) {
        _purchaseController.add(PurchaseError(error.toString()));
      },
    );

    // Restore purchases (handles reinstalls and new devices)
    await _iap.restorePurchases();

    await _loadProductDetails();
  }

  Future<void> _loadPersistedPurchases() async {
    final prefs = await SharedPreferences.getInstance();
    _purchasedCategories =
        (prefs.getStringList(_BillingKeys.purchasedCategories) ?? []).toSet();
    _purchasedSubcategories =
        (prefs.getStringList(_BillingKeys.purchasedSubcategories) ?? [])
            .toSet();
    _singleUseUnlocked =
        (prefs.getStringList(_BillingKeys.singleUseUnlocked) ?? []).toSet();
  }

  Future<void> _loadProductDetails() async {
    final response = await _iap.queryProductDetails(ProductIds.all);
    _products = {
      for (final p in response.productDetails) p.id: p,
    };
  }

  // ── Purchase stream handling ──────────────────────────────────────────────

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _handleSuccessfulPurchase(purchase.productID);
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          _purchaseController.add(PurchaseSuccess(purchase.productID));
        case PurchaseStatus.error:
          _purchaseController.add(
            PurchaseError(purchase.error?.message ?? 'Bilinmeyen hata'),
          );
        case PurchaseStatus.canceled:
          _purchaseController.add(const PurchaseCancelled());
        case PurchaseStatus.pending:
          _purchaseController.add(const PurchasePending());
      }
    }
  }

  Future<void> _handleSuccessfulPurchase(String productId) async {
    final prefs = await SharedPreferences.getInstance();

    if (ProductIds.categories.contains(productId)) {
      _purchasedCategories.add(productId);
      await prefs.setStringList(
        _BillingKeys.purchasedCategories,
        _purchasedCategories.toList(),
      );
    } else if (ProductIds.subcategories.contains(productId)) {
      _purchasedSubcategories.add(productId);
      await prefs.setStringList(
        _BillingKeys.purchasedSubcategories,
        _purchasedSubcategories.toList(),
      );
    }
  }

  // ── Public actions ────────────────────────────────────────────────────────

  Future<void> purchase(String productId) async {
    if (!_storeAvailable) {
      _purchaseController.add(const PurchaseError('Mağaza kullanılamıyor'));
      return;
    }
    final product = _products[productId];
    if (product == null) {
      _purchaseController.add(const PurchaseError('Ürün bulunamadı'));
      return;
    }
    final param = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> addSingleUseUnlock(String subcategoryId) async {
    _singleUseUnlocked.add(subcategoryId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _BillingKeys.singleUseUnlocked,
      _singleUseUnlocked.toList(),
    );
  }

  Future<void> consumeSingleUseUnlocks() async {
    _singleUseUnlocked.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_BillingKeys.singleUseUnlocked);
  }

  void dispose() {
    _subscription?.cancel();
    _purchaseController.close();
  }
}
