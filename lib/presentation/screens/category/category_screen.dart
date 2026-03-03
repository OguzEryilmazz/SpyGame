import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ads/ad_manager.dart';
import '../../../core/billing/billing_manager.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/category.dart';
import '../../providers/ads_provider.dart';
import '../../providers/billing_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/game_provider.dart';
import '../../widgets/banner_ad_widget.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/spy_button.dart';

// ── Icon mapping ──────────────────────────────────────────────────────────────

/// Maps the JSON "iconName" string to a Material [IconData].
/// Mirrors Kotlin's CategoryDataManager.getIconByName().
IconData _iconFor(String name) => switch (name) {
  'work' => Icons.work,
  'restaurant' => Icons.restaurant,
  'apple' => Icons.food_bank,
  'palette' => Icons.palette,
  'sports' => Icons.sports,
  'music' => Icons.music_note,
  'place' => Icons.place,
  'pets' => Icons.pets,
  'directions_car' => Icons.directions_car,
  'sports_esports' => Icons.sports_basketball,
  'computer' => Icons.computer,
  'checkroom' => Icons.checkroom,
  'school' => Icons.school,
  'book' => Icons.book,
  'wb_sunny' => Icons.wb_sunny,
  'mood' => Icons.mood,
  'home' => Icons.home,
  'public' => Icons.public,
  'shuffle' => Icons.shuffle,
  'cake' => Icons.cake,
  'local_cafe' => Icons.local_cafe,
  'store' => Icons.store,
  'movie' => Icons.movie,
  'live_tv' => Icons.live_tv,
  'play_circle' => Icons.play_circle,
  _ => Icons.category,
};

/// Parses a hex color string like "#2196F3" into a Flutter [Color].
Color _colorFrom(String hex) {
  final sanitized = hex.replaceAll('#', '');
  return Color(int.parse('FF$sanitized', radix: 16));
}

// ── Filter enum ───────────────────────────────────────────────────────────────

enum _FilterType { all, favorites, unlocked }

// ── CategoryScreen ────────────────────────────────────────────────────────────

/// Mirrors Kotlin CategoryScreen.kt.
///
/// Fetches categories from [categoriesProvider], tracks favorites via
/// [favoritesProvider], and navigates forward via [onNext] / back via [onBack].
class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({super.key, required this.onBack, required this.onNext});

  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  // ── local UI state ────────────────────────────────────────────────────────
  _FilterType _filter = _FilterType.all;
  String _searchQuery = '';
  bool _searchActive = false;
  final TextEditingController _searchController = TextEditingController();

  // Multi-select: category id → chosen SubCategory (null = flat category)
  final Map<String, SubCategory?> _selectedMap = {};

  // Which category card is expanded (shows hints preview)
  String? _expandedId;

  // Subcategory dialog state
  Category? _dialogCategory;

  // Transient snackbar message
  String? _message;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showMessage(String msg) {
    setState(() => _message = msg);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _message = null);
    });
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  List<Category> _applyFilters(List<Category> all, Set<String> favoriteIds) {
    var list = all;

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((c) => c.name.toLowerCase().contains(q)).toList();
    }

    return switch (_filter) {
      _FilterType.favorites =>
        list.where((c) => favoriteIds.contains(c.id)).toList(),
      _FilterType.unlocked => list.where((c) => !c.isLocked).toList(),
      _FilterType.all => list,
    };
  }

  void _onCategoryTap(Category cat) {
    if (cat.isLocked) return;

    if (cat.hasSubcategories) {
      setState(() => _dialogCategory = cat);
      return;
    }

    // Tap on the card body: expand/collapse only.
    setState(() {
      _expandedId = (_expandedId == cat.id) ? null : cat.id;
    });
  }

  void _onCategorySelect(Category cat) {
    if (cat.isLocked) return;
    setState(() {
      if (_selectedMap.containsKey(cat.id)) {
        _selectedMap.remove(cat.id);
      } else {
        _selectedMap[cat.id] = null;
      }
    });
  }

  void _watchAdForSubcategory(String subcategoryId) {
    AdManager.instance.showRewarded(
      onRewarded: () async {
        await ref
            .read(purchaseStateProvider.notifier)
            .addSingleUseUnlock(subcategoryId);
        _showMessage('Alt kategori bu oyun için açıldı!');
      },
      onNotReady: () =>
          _showMessage('Reklam henüz hazır değil, lütfen tekrar deneyin.'),
    );
  }

  void _onSubCategoryToggle(Category parent, SubCategory sub) {
    if (!sub.isUnlocked) {
      _showMessage('Bu alt kategori kilitli.');
      return;
    }
    final key = '${parent.id}::${sub.id}';
    setState(() {
      if (_selectedMap.containsKey(key)) {
        _selectedMap.remove(key);
      } else {
        _selectedMap[key] = sub;
      }
      // Keep dialog open so user can select multiple subcategories.
      // Dialog closes via the X / "Kapat" button or tapping outside.
    });
  }

  void _startGame() {
    if (_selectedMap.isEmpty) return;

    // Pick a random selection from the chosen (category, sub) pairs.
    final entries = _selectedMap.entries.toList()..shuffle();
    final chosen = entries.first;

    // Resolve the SubCategory to play
    final sub = chosen.value;
    if (sub != null) {
      ref.read(gameStateProvider.notifier).selectSubCategory(sub);
    } else {
      // Flat category — wrap as synthetic SubCategory
      // Find the category from the loaded list
      final cats = ref.read(enrichedCategoriesProvider).valueOrNull ?? [];
      final catId = chosen.key.split('::').first;
      final cat = cats.firstWhere(
        (c) => c.id == catId,
        orElse: () => cats.first,
      );
      final flatSub = cat.playableSubCategories.first;
      ref.read(gameStateProvider.notifier).selectSubCategory(flatSub);
    }

    widget.onNext();
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(enrichedCategoriesProvider);
    final favoriteIds = ref.watch(favoritesProvider);

    // Purchase feedback
    ref.listen<AsyncValue<PurchaseResult>>(purchaseStreamProvider, (_, next) {
      next.whenData((result) {
        switch (result) {
          case PurchaseSuccess():
            _showMessage('Satın alma başarılı!');
          case PurchaseError(:final message):
            _showMessage('Hata: $message');
          case PurchasePending():
            _showMessage('Satın alma işleniyor...');
          case PurchaseCancelled():
            break;
        }
      });
    });

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: const BannerAdWidget(),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _TopBar(
                    onBack: widget.onBack,
                    selectedCount: _selectedMap.keys
                        .map((k) => k.split('::').first)
                        .toSet()
                        .length,
                    searchActive: _searchActive,
                    searchController: _searchController,
                    onSearchToggle: () => setState(() {
                      _searchActive = !_searchActive;
                      if (!_searchActive) {
                        _searchController.clear();
                        _searchQuery = '';
                      }
                    }),
                    onSearchChanged: (q) => setState(() => _searchQuery = q),
                    onSearchClear: () => setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    }),
                  ),

                  // ── Filter chips (only when search is active) ────────────
                  if (_searchActive)
                    _FilterChips(
                      current: _filter,
                      favoriteCount: favoriteIds.length,
                      unlockedCount:
                          categoriesAsync.valueOrNull
                              ?.where((c) => !c.isLocked)
                              .length ??
                          0,
                      onChanged: (f) => setState(() => _filter = f),
                    ),

                  // ── Message banner ───────────────────────────────────────
                  if (_message != null) _MessageBanner(message: _message!),

                  // ── Body ─────────────────────────────────────────────────
                  Expanded(
                    child: categoriesAsync.when(
                      loading: () => const _LoadingBody(),
                      error: (e, _) => _ErrorBody(message: e.toString()),
                      data: (all) {
                        final filtered = _applyFilters(all, favoriteIds);

                        if (filtered.isEmpty &&
                            _filter == _FilterType.favorites) {
                          return _EmptyFavorites(
                            onAdd: () => setState(() {
                              _filter = _FilterType.all;
                              _searchActive = true;
                            }),
                          );
                        }

                        if (filtered.isEmpty) {
                          return _EmptySearch(query: _searchQuery);
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final cat = filtered[index];
                            final isFav = favoriteIds.contains(cat.id);
                            // A category is "selected" if ANY of its keys are in _selectedMap
                            final isSelected = _selectedMap.keys.any(
                              (k) => k.split('::').first == cat.id,
                            );
                            final isExpanded = _expandedId == cat.id;

                            return _CategoryCard(
                              category: cat,
                              isFavorite: isFav,
                              isSelected: isSelected,
                              isExpanded: isExpanded,
                              onTap: () => _onCategoryTap(cat),
                              onSelectTap: () => _onCategorySelect(cat),
                              onFavoriteTap: () => ref
                                  .read(favoritesProvider.notifier)
                                  .toggle(cat.id),
                              onUnlock: cat.isLocked
                                  ? () => ref
                                        .read(purchaseStateProvider.notifier)
                                        .purchase(cat.id)
                                  : null,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),

              // ── Subcategory dialog ───────────────────────────────────────
              if (_dialogCategory != null)
                _SubcategoryDialog(
                  category: _dialogCategory!,
                  selectedKeys: _selectedMap.keys.toSet(),
                  onToggle: (sub) =>
                      _onSubCategoryToggle(_dialogCategory!, sub),
                  onDismiss: () => setState(() => _dialogCategory = null),
                  onWatchAd: (subId) => _watchAdForSubcategory(subId),
                  onPurchaseSub: (subId) =>
                      ref.read(purchaseStateProvider.notifier).purchase(subId),
                ),

              // ── Start game button ────────────────────────────────────────
              if (_selectedMap.isNotEmpty)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _StartBar(
                    selectedCount: _selectedMap.keys
                        .map((k) => k.split('::').first)
                        .toSet()
                        .length,
                    onStart: _startGame,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.onBack,
    required this.selectedCount,
    required this.searchActive,
    required this.searchController,
    required this.onSearchToggle,
    required this.onSearchChanged,
    required this.onSearchClear,
  });

  final VoidCallback onBack;
  final int selectedCount;
  final bool searchActive;
  final TextEditingController searchController;
  final VoidCallback onSearchToggle;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              // Back
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.counterBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kategori Seç',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      selectedCount == 0
                          ? 'Açık kategorilerden seçin'
                          : '$selectedCount kategori seçildi',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: .8),
                      ),
                    ),
                  ],
                ),
              ),
              // Search toggle
              GestureDetector(
                onTap: onSearchToggle,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: searchActive
                        ? Colors.white.withValues(alpha: .3)
                        : AppColors.counterBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          // Search field
          if (searchActive) ...[
            const SizedBox(height: 10),
            Material(
              color: Colors.transparent,
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: 'Kategori ara...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: .6),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white.withValues(alpha: .7),
                  ),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.white.withValues(alpha: .7),
                          ),
                          onPressed: onSearchClear,
                        )
                      : null,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: .5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Filter chips ──────────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.current,
    required this.favoriteCount,
    required this.unlockedCount,
    required this.onChanged,
  });

  final _FilterType current;
  final int favoriteCount;
  final int unlockedCount;
  final ValueChanged<_FilterType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _Chip(
              label: 'Tümü',
              selected: current == _FilterType.all,
              onTap: () => onChanged(_FilterType.all),
            ),
            const SizedBox(width: 8),
            _Chip(
              label: 'Favoriler ($favoriteCount)',
              icon: Icons.star,
              selected: current == _FilterType.favorites,
              onTap: () => onChanged(_FilterType.favorites),
            ),
            const SizedBox(width: 8),
            _Chip(
              label: 'Açık ($unlockedCount)',
              selected: current == _FilterType.unlocked,
              onTap: () => onChanged(_FilterType.unlocked),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withValues(alpha: .3)
              : Colors.white.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? Colors.white.withValues(alpha: .8)
                : Colors.white.withValues(alpha: .3),
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 14),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: selected ? 1 : .8),
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Message banner ────────────────────────────────────────────────────────────

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final isSuccess = message.contains('başarıyla') || message.contains('🎉');
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSuccess
              ? Colors.green.withValues(alpha: .9)
              : Colors.red.withValues(alpha: .9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}

// ── Loading / error / empty states ───────────────────────────────────────────

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Kategoriler yükleniyor...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Hata: $message',
        style: TextStyle(color: Colors.white.withValues(alpha: .8)),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_border,
            color: Colors.white.withValues(alpha: .5),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz favori eklemediniz.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'Kategori ekle',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        query.isNotEmpty
            ? '"$query" için sonuç bulunamadı'
            : 'Henüz kategori bulunmuyor',
        style: TextStyle(
          color: Colors.white.withValues(alpha: .7),
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ── Category card ─────────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.isFavorite,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
    required this.onSelectTap,
    required this.onFavoriteTap,
    this.onUnlock,
  });

  final Category category;
  final bool isFavorite;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onSelectTap;
  final VoidCallback onFavoriteTap;
  final VoidCallback? onUnlock;

  @override
  Widget build(BuildContext context) {
    final color = _colorFrom(category.colorHex);
    final icon = _iconFor(category.iconName);
    final locked = category.isLocked;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isExpanded ? Colors.white : Colors.white.withValues(alpha: .88),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isExpanded ? .15 : .08),
            blurRadius: isExpanded ? 12 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: locked ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row ───────────────────────────────────────────
                Row(
                  children: [
                    // Icon box
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: locked
                            ? Colors.grey.withValues(alpha: .2)
                            : color.withValues(alpha: .15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        locked ? Icons.lock : icon,
                        color: locked ? Colors.grey : color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Name + subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: locked ? Colors.grey : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.category,
                                size: 14,
                                color: locked
                                    ? Colors.grey.withValues(alpha: .6)
                                    : color.withValues(alpha: .7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                category.hasSubcategories
                                    ? '${category.subcategories.length} alt kategori'
                                    : '${category.items.length} öğe',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: locked
                                      ? Colors.grey.withValues(alpha: .6)
                                      : color.withValues(alpha: .8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Favourite + selected badges
                    if (!locked) ...[
                      GestureDetector(
                        onTap: onFavoriteTap,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isFavorite
                                ? color.withValues(alpha: .15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isFavorite ? Icons.star : Icons.star_border,
                            color: isFavorite
                                ? color
                                : Colors.grey.withValues(alpha: .5),
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: onSelectTap,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color
                                : Colors.grey.withValues(alpha: .15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.check,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.withValues(alpha: .4),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // ── Locked: price button ─────────────────────────────────
                if (locked) ...[
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: onUnlock,
                      icon: const Icon(Icons.shopping_cart, size: 18),
                      label: Text(
                        'Kilidi Aç'
                        '${category.priceTL > 0 ? ' — ₺${category.priceTL.toStringAsFixed(2)}' : ''}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        shape: RoundedCornerShape(12),
                        disabledBackgroundColor: color.withValues(alpha: .6),
                        disabledForegroundColor: Colors.white70,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Bu kategoriyi oynamak için satın alın',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.withValues(alpha: .7),
                      ),
                    ),
                  ),
                ],

                // ── Expanded: hints preview ──────────────────────────────
                if (isExpanded && !locked && category.hints.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Divider(color: color.withValues(alpha: .3), height: 1),
                  const SizedBox(height: 10),
                  Text(
                    'İpuçları',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...category.hints
                      .take(3)
                      .map(
                        (h) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: .5),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  h,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  if (category.hints.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '+ ${category.hints.length - 3} ipucu daha',
                        style: TextStyle(
                          fontSize: 12,
                          color: color.withValues(alpha: .7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Inline helper so card can use ElevatedButton.styleFrom shape
class RoundedCornerShape extends RoundedRectangleBorder {
  RoundedCornerShape(double radius)
    : super(borderRadius: BorderRadius.circular(radius));
}

// ── Subcategory dialog ────────────────────────────────────────────────────────

class _SubcategoryDialog extends StatelessWidget {
  const _SubcategoryDialog({
    required this.category,
    required this.selectedKeys,
    required this.onToggle,
    required this.onDismiss,
    this.onWatchAd,
    this.onPurchaseSub,
  });

  final Category category;
  final Set<String> selectedKeys;
  final ValueChanged<SubCategory> onToggle;
  final VoidCallback onDismiss;
  final ValueChanged<String>? onWatchAd;
  final ValueChanged<String>? onPurchaseSub;

  @override
  Widget build(BuildContext context) {
    final color = _colorFrom(category.colorHex);
    final icon = _iconFor(category.iconName);
    final selectedSubIds = selectedKeys
        .where((k) => k.startsWith('${category.id}::'))
        .map((k) => k.split('::').last)
        .toSet();

    return GestureDetector(
      onTap: onDismiss, // tap outside → dismiss
      child: Container(
        color: Colors.black.withValues(alpha: .5),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // absorb taps inside dialog
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * .7,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Dialog header ────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: .15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: color, size: 26),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                selectedSubIds.isEmpty
                                    ? 'Alt kategori seçin'
                                    : '${selectedSubIds.length} seçildi',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: selectedSubIds.isEmpty
                                      ? Colors.grey
                                      : color,
                                  fontWeight: selectedSubIds.isEmpty
                                      ? FontWeight.normal
                                      : FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: onDismiss,
                          icon: const Icon(Icons.close, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // ── Sub-category list ────────────────────────────────
                  Flexible(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      shrinkWrap: true,
                      itemCount: category.subcategories.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final sub = category.subcategories[index];
                        final isSelected = selectedSubIds.contains(sub.id);
                        return _SubcategoryItem(
                          sub: sub,
                          categoryColor: color,
                          categoryIcon: icon,
                          isSelected: isSelected,
                          onTap: () => onToggle(sub),
                          onWatchAd: (!sub.isUnlocked && sub.unlockedByAd)
                              ? () => onWatchAd?.call(sub.id)
                              : null,
                          onPurchase: (!sub.isUnlocked && !sub.unlockedByAd)
                              ? () => onPurchaseSub?.call(sub.id)
                              : null,
                        );
                      },
                    ),
                  ),

                  // ── Close button ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: TextButton.icon(
                      onPressed: onDismiss,
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text(
                        'Kapat',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: TextButton.styleFrom(foregroundColor: color),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SubcategoryItem extends StatelessWidget {
  const _SubcategoryItem({
    required this.sub,
    required this.categoryColor,
    required this.categoryIcon,
    required this.isSelected,
    required this.onTap,
    this.onWatchAd,
    this.onPurchase,
  });

  final SubCategory sub;
  final Color categoryColor;
  final IconData categoryIcon;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onWatchAd;
  final VoidCallback? onPurchase;

  @override
  Widget build(BuildContext context) {
    final unlocked = sub.isUnlocked;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 72,
        decoration: BoxDecoration(
          color: isSelected
              ? categoryColor
              : unlocked
              ? Colors.white
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? null
              : Border.all(
                  color: unlocked
                      ? const Color(0xFFF0F0F0)
                      : const Color(0xFFE0E0E0),
                ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: categoryColor.withValues(alpha: .3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? Center(
                child: Text(
                  sub.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: unlocked
                            ? categoryColor.withValues(alpha: .1)
                            : const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        unlocked ? categoryIcon : Icons.lock,
                        color: unlocked ? categoryColor : Colors.grey,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sub.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: unlocked ? Colors.black87 : Colors.grey,
                            ),
                          ),
                          if (unlocked)
                            Text(
                              '${sub.items.length} kelime',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (!unlocked) ...[
                      if (onWatchAd != null)
                        GestureDetector(
                          onTap: onWatchAd,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: categoryColor.withValues(alpha: .15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.play_circle_outline,
                                  color: categoryColor,
                                  size: 15,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Reklam',
                                  style: TextStyle(
                                    color: categoryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (onPurchase != null)
                        GestureDetector(
                          onTap: onPurchase,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: categoryColor.withValues(alpha: .15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.shopping_cart,
                                  color: categoryColor,
                                  size: 15,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Satın Al',
                                  style: TextStyle(
                                    color: categoryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (onWatchAd == null && onPurchase == null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.lock,
                            color: categoryColor,
                            size: 16,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

// ── Start bar ─────────────────────────────────────────────────────────────────

class _StartBar extends StatelessWidget {
  const _StartBar({required this.selectedCount, required this.onStart});

  final int selectedCount;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.bottomScrim),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: SpyButton(
          label: 'Oyunu Başlat ($selectedCount kategori)',
          icon: Icons.play_arrow,
          onTap: onStart,
        ),
      ),
    );
  }
}
