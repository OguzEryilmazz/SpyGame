import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/billing/billing_manager.dart';

// ── BillingManager provider ───────────────────────────────────────────────────

final billingManagerProvider = Provider<BillingManager>((ref) {
  return BillingManager.instance;
});

// ── Purchase stream provider ──────────────────────────────────────────────────

final purchaseStreamProvider = StreamProvider<PurchaseResult>((ref) {
  return ref.read(billingManagerProvider).purchaseStream;
});

// ── Purchase state ────────────────────────────────────────────────────────────

class PurchaseState {
  final Set<String> purchasedIds;
  final Set<String> singleUseUnlockedIds;
  final bool isPurchasing;
  final String? purchasingId;

  const PurchaseState({
    required this.purchasedIds,
    required this.singleUseUnlockedIds,
    required this.isPurchasing,
    this.purchasingId,
  });

  PurchaseState copyWith({
    Set<String>? purchasedIds,
    Set<String>? singleUseUnlockedIds,
    bool? isPurchasing,
    String? purchasingId,
  }) =>
      PurchaseState(
        purchasedIds: purchasedIds ?? this.purchasedIds,
        singleUseUnlockedIds: singleUseUnlockedIds ?? this.singleUseUnlockedIds,
        isPurchasing: isPurchasing ?? this.isPurchasing,
        purchasingId: purchasingId ?? this.purchasingId,
      );

  bool isUnlocked(String id) =>
      purchasedIds.contains(id) || singleUseUnlockedIds.contains(id);
}

// ── PurchaseStateNotifier ─────────────────────────────────────────────────────

class PurchaseStateNotifier extends Notifier<PurchaseState> {
  @override
  PurchaseState build() {
    // Listen to purchase stream and update state on each event
    ref.listen<AsyncValue<PurchaseResult>>(
      purchaseStreamProvider,
      (_, next) {
        next.whenData((result) {
          if (result is PurchaseSuccess) {
            state = state.copyWith(
              purchasedIds: {...state.purchasedIds, result.productId},
              isPurchasing: false,
              purchasingId: null,
            );
          } else if (result is PurchaseError || result is PurchaseCancelled) {
            state = state.copyWith(
              isPurchasing: false,
              purchasingId: null,
            );
          }
        });
      },
    );

    final billing = BillingManager.instance;
    return PurchaseState(
      purchasedIds: Set.from(billing.allPurchasedIds),
      singleUseUnlockedIds: Set.from(billing.singleUseUnlockedIds),
      isPurchasing: false,
    );
  }

  Future<void> purchase(String productId) async {
    state = state.copyWith(isPurchasing: true, purchasingId: productId);
    await ref.read(billingManagerProvider).purchase(productId);
  }

  Future<void> addSingleUseUnlock(String subcategoryId) async {
    await ref.read(billingManagerProvider).addSingleUseUnlock(subcategoryId);
    state = state.copyWith(
      singleUseUnlockedIds: {...state.singleUseUnlockedIds, subcategoryId},
    );
  }

  Future<void> consumeSingleUseUnlocks() async {
    await ref.read(billingManagerProvider).consumeSingleUseUnlocks();
    state = state.copyWith(singleUseUnlockedIds: {});
  }
}

final purchaseStateProvider =
    NotifierProvider<PurchaseStateNotifier, PurchaseState>(
  PurchaseStateNotifier.new,
);
