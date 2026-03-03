import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/category_local_datasource.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/models/category.dart';
import '../../domain/repositories/category_repository.dart';
import 'billing_provider.dart';

// ── Infrastructure ────────────────────────────────────────────────────────────

final categoryDataSourceProvider = Provider<CategoryLocalDataSource>(
  (_) => CategoryLocalDataSource(),
);

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepositoryImpl(ref.read(categoryDataSourceProvider)),
);

// ── Raw category list (from JSON asset) ───────────────────────────────────────

/// Loads all categories once and caches them for the app lifetime.
final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.read(categoryRepositoryProvider).getCategories();
});

// ── Favorites ─────────────────────────────────────────────────────────────────

/// In-memory set of favourite category IDs.
/// Notifier persists changes to the repository (currently in-memory;
/// swap [CategoryRepositoryImpl] for SharedPreferences later).
class FavoritesNotifier extends Notifier<Set<String>> {
  late CategoryRepository _repo;

  @override
  Set<String> build() {
    _repo = ref.read(categoryRepositoryProvider);
    // Kick off async load without blocking build()
    _loadFromRepo();
    return {};
  }

  Future<void> _loadFromRepo() async {
    final ids = await _repo.getFavoriteIds();
    state = ids.toSet();
  }

  Future<void> toggle(String categoryId) async {
    if (state.contains(categoryId)) {
      state = {...state}..remove(categoryId);
      await _repo.removeFavorite(categoryId);
    } else {
      state = {...state, categoryId};
      await _repo.saveFavorite(categoryId);
    }
  }

  bool isFavorite(String categoryId) => state.contains(categoryId);
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<String>>(
  FavoritesNotifier.new,
);

// ── Derived providers ─────────────────────────────────────────────────────────

final freeCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final all = await ref.watch(categoriesProvider.future);
  return all.where((c) => !c.isLocked).toList();
});

final lockedCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final all = await ref.watch(categoriesProvider.future);
  return all.where((c) => c.isLocked).toList();
});

/// Returns all playable sub-categories for a given category id.
final subCategoriesProvider =
    FutureProvider.family<List<SubCategory>, String>((ref, categoryId) async {
  final all = await ref.watch(categoriesProvider.future);
  final category = all.firstWhere(
    (c) => c.id == categoryId,
    orElse: () => throw StateError('Category not found: $categoryId'),
  );
  return category.playableSubCategories;
});

// ── Enriched categories (purchase-aware) ──────────────────────────────────────

/// Categories with purchase and ad-unlock state overlaid.
/// CategoryScreen watches this instead of [categoriesProvider].
final enrichedCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final all = await ref.watch(categoriesProvider.future);
  final purchaseState = ref.watch(purchaseStateProvider);

  return all.map((cat) {
    // Whole category purchased → unlock it and all its subcategories
    if (cat.isLocked && purchaseState.isUnlocked(cat.id)) {
      final unlockedSubs = cat.subcategories
          .map((sub) => sub.copyWith(isUnlocked: true))
          .toList();
      return cat.copyWith(isLocked: false, subcategories: unlockedSubs);
    }

    // Overlay individual subcategory unlock state
    if (cat.hasSubcategories) {
      final enrichedSubs = cat.subcategories.map((sub) {
        if (!sub.isUnlocked && purchaseState.isUnlocked(sub.id)) {
          return sub.copyWith(isUnlocked: true);
        }
        return sub;
      }).toList();
      return cat.copyWith(subcategories: enrichedSubs);
    }

    return cat;
  }).toList();
});
