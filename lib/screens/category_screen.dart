import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ads/ad_providers.dart';
import '../ads/rewarded_ad_manager.dart';
import '../billing/iap_service.dart';
import '../models/player.dart';
import '../models/game_player.dart';
import 'setup_screen.dart' show gameDurationProvider, showHintsProvider;
import '../billing/iap_products.dart';

// ---------------------------------------------------------------------------
// DATA MODELS
// ---------------------------------------------------------------------------

class Subcategory {
  final String id;
  final String name;
  final List<String> items;
  final List<String> hints;
  final bool isUnlocked;
  final bool unlockedByAd;

  const Subcategory({
    required this.id,
    required this.name,
    required this.items,
    required this.hints,
    this.isUnlocked = false,
    this.unlockedByAd = false,
  });

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id: json['id'] as String,
      name: json['name'] as String,
      items: List<String>.from(json['items'] as List? ?? []),
      hints: List<String>.from(json['hints'] as List? ?? []),
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedByAd: json['unlockedByAd'] as bool? ?? false,
    );
  }
}

class Category {
  final String id;
  final String name;
  final String iconName;
  final Color color;
  final List<String> items;
  final List<String> hints;
  final bool hasSubcategories;
  final List<Subcategory> subcategories;
  final bool isFavorite;
  final bool isLocked;
  final double priceTL;

  const Category({
    required this.id,
    required this.name,
    required this.iconName,
    required this.color,
    required this.items,
    required this.hints,
    required this.hasSubcategories,
    required this.subcategories,
    this.isFavorite = false,
    this.isLocked = false,
    this.priceTL = 0.0,
  });

  Category copyWith({bool? isFavorite, bool? isLocked}) => Category(
    id: id,
    name: name,
    iconName: iconName,
    color: color,
    items: items,
    hints: hints,
    hasSubcategories: hasSubcategories,
    subcategories: subcategories,
    isFavorite: isFavorite ?? this.isFavorite,
    isLocked: isLocked ?? this.isLocked,
    priceTL: priceTL,
  );

  factory Category.fromJson(Map<String, dynamic> json) {
    final colorHex =
    (json['colorHex'] as String? ?? '#2196F3').replaceFirst('#', '');
    final color = Color(int.parse('FF$colorHex', radix: 16));

    List<Subcategory> subs = [];
    if (json['hasSubcategories'] == true && json['subcategories'] != null) {
      for (final s in json['subcategories'] as List) {
        subs.add(Subcategory.fromJson(s as Map<String, dynamic>));
      }
    }

    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      iconName: json['iconName'] as String? ?? 'category',
      color: color,
      items: List<String>.from(json['items'] as List? ?? []),
      hints: List<String>.from(json['hints'] as List? ?? []),
      hasSubcategories: json['hasSubcategories'] as bool? ?? false,
      subcategories: subs,
      isLocked: json['isLocked'] as bool? ?? false,
      priceTL: (json['priceTL'] as num? ?? 0).toDouble(),
    );
  }

  IconData get icon => _iconFromName(iconName);

  static IconData _iconFromName(String name) {
    const map = <String, IconData>{
      'work': Icons.work_outline_rounded,
      'restaurant': Icons.restaurant_rounded,
      'apple': Icons.apple_rounded,
      'palette': Icons.palette_rounded,
      'cake': Icons.cake_rounded,
      'local_cafe': Icons.local_cafe_rounded,
      'store': Icons.storefront_rounded,
      'sports': Icons.sports_rounded,
      'place': Icons.place_rounded,
      'directions_car': Icons.directions_car_rounded,
      'computer': Icons.computer_rounded,
      'checkroom': Icons.checkroom_rounded,
      'school': Icons.school_rounded,
      'sports_esports': Icons.sports_esports_rounded,
      'book': Icons.menu_book_rounded,
      'wb_sunny': Icons.wb_sunny_rounded,
      'mood': Icons.mood_rounded,
      'home': Icons.home_rounded,
      'pets': Icons.pets_rounded,
      'music': Icons.music_note_rounded,
      'sports_basketball': Icons.sports_basketball_rounded,
      'public': Icons.public_rounded,
      'movie': Icons.movie_rounded,
      'live_tv': Icons.live_tv_rounded,
      'play_circle': Icons.play_circle_rounded,
    };
    return map[name] ?? Icons.category_rounded;
  }
}

// ---------------------------------------------------------------------------
// PROVIDERS
// ---------------------------------------------------------------------------

const _favoritesKey = 'favorite_category_ids';
const _unlockedCategoriesKey = 'unlocked_category_ids';
const _unlockedSubcategoriesKey = 'unlocked_subcategory_ids';

final categoriesProvider =
StateNotifierProvider<CategoriesNotifier, AsyncValue<List<Category>>>(
      (ref) => CategoriesNotifier(),
);

class CategoriesNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  CategoriesNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  List<Category> _categories = [];

  Future<void> _load() async {
    try {
      final raw = await rootBundle.loadString('assets/categories.json');
      final data = jsonDecode(raw) as Map<String, dynamic>;
      _categories = (data['categories'] as List)
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();

      final prefs = await SharedPreferences.getInstance();
      final savedFavIds =
          prefs.getStringList(_favoritesKey)?.toSet() ?? <String>{};
      final unlockedCatIds =
          prefs.getStringList(_unlockedCategoriesKey)?.toSet() ?? <String>{};
      final unlockedSubIds =
          prefs.getStringList(_unlockedSubcategoriesKey)?.toSet() ?? <String>{};

      _categories = _categories.map((c) {
        final catUnlocked = unlockedCatIds.contains(c.id);

        final updatedSubs = c.subcategories.map((sub) {
          final subUnlocked = sub.isUnlocked || unlockedSubIds.contains(sub.id);
          return Subcategory(
            id: sub.id,
            name: sub.name,
            items: sub.items,
            hints: sub.hints,
            isUnlocked: subUnlocked,
            unlockedByAd: sub.unlockedByAd,
          );
        }).toList();

        return Category(
          id: c.id,
          name: c.name,
          iconName: c.iconName,
          color: c.color,
          items: c.items,
          hints: c.hints,
          hasSubcategories: c.hasSubcategories,
          subcategories: updatedSubs,
          isFavorite: savedFavIds.contains(c.id),
          isLocked: c.isLocked && !catUnlocked,
          priceTL: c.priceTL,
        );
      }).toList();

      state = AsyncValue.data(List.unmodifiable(_categories));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleFavorite(String id) async {
    _categories = _categories.map((c) {
      if (c.id == id) return c.copyWith(isFavorite: !c.isFavorite);
      return c;
    }).toList();
    state = AsyncValue.data(List.unmodifiable(_categories));

    final favoriteIds =
    _categories.where((c) => c.isFavorite).map((c) => c.id).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favoriteIds);
  }

  Future<void> unlockCategory(String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids =
        prefs.getStringList(_unlockedCategoriesKey)?.toSet() ?? <String>{};
    ids.add(categoryId);
    await prefs.setStringList(_unlockedCategoriesKey, ids.toList());

    _categories = _categories.map((c) {
      if (c.id == categoryId) return c.copyWith(isLocked: false);
      return c;
    }).toList();
    state = AsyncValue.data(List.unmodifiable(_categories));
  }

  Future<void> unlockSubcategory(String subcategoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids =
        prefs.getStringList(_unlockedSubcategoriesKey)?.toSet() ?? <String>{};
    ids.add(subcategoryId);
    await prefs.setStringList(_unlockedSubcategoriesKey, ids.toList());

    _categories = _categories.map((cat) {
      final updatedSubs = cat.subcategories.map((sub) {
        if (sub.id == subcategoryId) {
          return Subcategory(
            id: sub.id,
            name: sub.name,
            items: sub.items,
            hints: sub.hints,
            isUnlocked: true,
            unlockedByAd: sub.unlockedByAd,
          );
        }
        return sub;
      }).toList();

      return Category(
        id: cat.id,
        name: cat.name,
        iconName: cat.iconName,
        color: cat.color,
        items: cat.items,
        hints: cat.hints,
        hasSubcategories: cat.hasSubcategories,
        subcategories: updatedSubs,
        isFavorite: cat.isFavorite,
        isLocked: cat.isLocked,
        priceTL: cat.priceTL,
      );
    }).toList();
    state = AsyncValue.data(List.unmodifiable(_categories));
  }
}

typedef CategorySelection = ({Category category, Subcategory? subcategory});

final selectedCategoriesProvider =
StateProvider<List<CategorySelection>>((ref) => []);

final categorySearchProvider = StateProvider<String>((ref) => '');

final searchBarVisibleProvider = StateProvider<bool>((ref) => false);

enum CategoryFilter { all, favorites }

final categoryFilterProvider =
StateProvider<CategoryFilter>((ref) => CategoryFilter.all);

// ---------------------------------------------------------------------------
// GAME STATE PROVIDER
// ---------------------------------------------------------------------------

class GameState {
  final List<GamePlayer> players;
  final Category category;
  final String word;
  final int durationMinutes;
  final bool showHints;

  const GameState({
    required this.players,
    required this.category,
    required this.word,
    required this.durationMinutes,
    required this.showHints,
  });
}

final gameStateProvider = StateProvider<GameState?>((ref) => null);

// ---------------------------------------------------------------------------
// ROLE ASSIGNMENT
// ---------------------------------------------------------------------------

List<GamePlayer> assignRoles(
    List<Player> players,
    List<String> items,
    List<String> hints,
    ) {
  final rng = Random();
  final shuffled = List<Player>.from(players)..shuffle(rng);
  final spyIndex = rng.nextInt(shuffled.length);
  final chosenItem =
  items.isNotEmpty ? items[rng.nextInt(items.length)] : 'PLAYER';

  return List.generate(shuffled.length, (i) {
    final p = shuffled[i];

    if (i == spyIndex) {
      return GamePlayer(
        id: p.id,
        name: p.name,
        color: p.selectedColor ?? const Color(0xFF9E9E9E),
        selectedCharacter: p.selectedCharacter,
        isSpy: true,
        assignedWord: 'SPY',
        hint: null,
        role: '',
      );
    }

    final hint = hints.isNotEmpty ? hints[rng.nextInt(hints.length)] : null;

    return GamePlayer(
      id: p.id,
      name: p.name,
      color: p.selectedColor ?? const Color(0xFF9E9E9E),
      selectedCharacter: p.selectedCharacter,
      isSpy: false,
      assignedWord: chosenItem,
      hint: hint,
      role: '',
    );
  });
}

// ---------------------------------------------------------------------------
// CATEGORY SCREEN
// ---------------------------------------------------------------------------

class CategoryScreen extends ConsumerStatefulWidget {
  final List<Player> players;

  const CategoryScreen({super.key, required this.players});

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleCategory(Category category) {
    if (category.isLocked) {
      _showPurchaseSheet(category);
      return;
    }
    final selected = ref.read(selectedCategoriesProvider);
    final exists = selected
        .any((s) => s.category.id == category.id && s.subcategory == null);
    if (exists) {
      ref.read(selectedCategoriesProvider.notifier).state = selected
          .where(
              (s) => !(s.category.id == category.id && s.subcategory == null))
          .toList();
    } else {
      ref.read(selectedCategoriesProvider.notifier).state = [
        ...selected,
        (category: category, subcategory: null),
      ];
    }
  }

  void _showPurchaseSheet(Category category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PurchaseSheet(
        category: category,
        onPurchaseSuccess: () async {
          await ref
              .read(categoriesProvider.notifier)
              .unlockCategory(category.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${category.name} kategorisi açıldı!'),
                backgroundColor: category.color,
              ),
            );
          }
        },
      ),
    );
  }

  void _showSubPurchaseSheet(Category category, Subcategory sub) {
    if (sub.unlockedByAd) {
      _watchAdForSubcategory(category, sub);
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SubPurchaseSheet(
        category: category,
        subcategory: sub,
        onPurchaseSuccess: () async {
          await ref
              .read(categoriesProvider.notifier)
              .unlockSubcategory(sub.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${sub.name} açıldı!'),
                backgroundColor: category.color,
              ),
            );
          }
        },
      ),
    );
  }

  void _watchAdForSubcategory(Category category, Subcategory sub) {
    final RewardedAdManager rewardedAd = ref.read(rewardedAdProvider);

    if (!rewardedAd.isAdReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reklam yükleniyor, lütfen bekleyin...')),
      );
      rewardedAd.loadAd(
        onAdLoaded: () {
          if (!mounted) return;
          _watchAdForSubcategory(category, sub);
        },
      );
      return;
    }

    rewardedAd.showAd(
      onUserEarnedReward: (amount, type) async {
        await ref.read(categoriesProvider.notifier).unlockSubcategory(sub.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${sub.name} açıldı!'),
            backgroundColor: category.color,
          ),
        );
      },
    );
  }

  void _startGame() {
    final selected = ref.read(selectedCategoriesProvider);
    if (selected.isEmpty) return;

    final rng = Random();
    final pick = selected[rng.nextInt(selected.length)];
    final cat = pick.category;
    final sub = pick.subcategory;

    final items = (sub != null) ? sub.items : cat.items;
    final hints = (sub != null) ? sub.hints : cat.hints;

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategoride öğe bulunamadı!')),
      );
      return;
    }

    final gamePlayers = assignRoles(widget.players, items, hints);
    final word = gamePlayers.firstWhere((p) => !p.isSpy).assignedWord;
    final duration = ref.read(gameDurationProvider);
    final showHints = ref.read(showHintsProvider);

    ref.read(gameStateProvider.notifier).state = GameState(
      players: gamePlayers,
      category: cat,
      word: word,
      durationMinutes: duration,
      showHints: showHints,
    );

    context.push('/game');
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selected = ref.watch(selectedCategoriesProvider);
    final searchText = ref.watch(categorySearchProvider);
    final filter = ref.watch(categoryFilterProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE91E63),
              Color(0xFF9C27B0),
              Color(0xFFF44336),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(
                selectedCount: selected.length,
                onBack: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
                searchController: _searchController,
              ),
              _FilterRow(),
              Expanded(
                child: categoriesAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  error: (e, _) => Center(
                    child: Text(
                      'Hata: $e',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  data: (cats) {
                    var filtered = cats;
                    if (searchText.isNotEmpty) {
                      filtered = filtered
                          .where((c) => c.name
                          .toLowerCase()
                          .contains(searchText.toLowerCase()))
                          .toList();
                    }
                    if (filter == CategoryFilter.favorites) {
                      filtered =
                          filtered.where((c) => c.isFavorite).toList();
                    }

                    if (filtered.isEmpty) {
                      return _EmptyState(filter: filter);
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) {
                        final cat = filtered[i];
                        final isSelected =
                        selected.any((s) => s.category.id == cat.id);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _CategoryCard(
                            category: cat,
                            isSelected: isSelected,
                            onTap: () {
                              if (cat.isLocked) {
                                _showPurchaseSheet(cat);
                              } else if (cat.hasSubcategories) {
                                _showSubcategoryDialog(cat);
                              } else {
                                _toggleCategory(cat);
                              }
                            },
                            onFavorite: () => ref
                                .read(categoriesProvider.notifier)
                                .toggleFavorite(cat.id),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: selected.isNotEmpty
          ? _StartGameButton(
        selectedCount: selected.length,
        totalItems: selected.fold(0, (sum, s) {
          if (s.subcategory != null) {
            return sum + s.subcategory!.items.length;
          }
          return sum + s.category.items.length;
        }),
        onPressed: _startGame,
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _showSubcategoryDialog(Category category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SubcategorySheet(
        category: category,
        onSelect: (sub) {
          if (!sub.isUnlocked) {
            _showSubPurchaseSheet(category, sub);
            return;
          }
          final selected = ref.read(selectedCategoriesProvider);
          final exists = selected.any((s) =>
          s.category.id == category.id && s.subcategory?.id == sub.id);
          if (exists) {
            ref.read(selectedCategoriesProvider.notifier).state = selected
                .where((s) => !(s.category.id == category.id &&
                s.subcategory?.id == sub.id))
                .toList();
          } else {
            ref.read(selectedCategoriesProvider.notifier).state = [
              ...selected,
              (category: category, subcategory: sub),
            ];
          }
        },
        selectedSubIds: ref
            .read(selectedCategoriesProvider)
            .where((s) => s.category.id == category.id)
            .map((s) => s.subcategory?.id ?? '')
            .toSet(),
        onUnlockSub: (sub) => _showSubPurchaseSheet(category, sub),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TOP BAR
// ---------------------------------------------------------------------------

class _TopBar extends ConsumerWidget {
  final int selectedCount;
  final VoidCallback onBack;
  final TextEditingController searchController;

  const _TopBar({
    required this.selectedCount,
    required this.onBack,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchBarVisible = ref.watch(searchBarVisibleProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _CircleBtn(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: onBack,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kategori Seç',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      selectedCount == 0
                          ? 'Kategori seçin ve oyunu başlatın'
                          : '$selectedCount kategori seçildi',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              _CircleBtn(
                icon: searchBarVisible
                    ? Icons.search_off_rounded
                    : Icons.search_rounded,
                onTap: () {
                  if (searchBarVisible) {
                    searchController.clear();
                    ref.read(categorySearchProvider.notifier).state = '';
                    ref.read(searchBarVisibleProvider.notifier).state = false;
                  } else {
                    ref.read(searchBarVisibleProvider.notifier).state = true;
                  }
                },
                active: searchBarVisible,
              ),
            ],
          ),
          if (searchBarVisible) ...[
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Kategori ara...',
                  hintStyle:
                  TextStyle(color: Colors.white.withOpacity(0.6)),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: Colors.white.withOpacity(0.7)),
                  border: InputBorder.none,
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: (v) =>
                ref.read(categorySearchProvider.notifier).state = v,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FILTER ROW
// ---------------------------------------------------------------------------

class _FilterRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(categoryFilterProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          _FilterChip(
            label: 'Tümü',
            selected: filter == CategoryFilter.all,
            onTap: () => ref.read(categoryFilterProvider.notifier).state =
                CategoryFilter.all,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Favoriler',
            icon: Icons.star_rounded,
            selected: filter == CategoryFilter.favorites,
            onTap: () => ref.read(categoryFilterProvider.notifier).state =
                CategoryFilter.favorites,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.white : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: Colors.white),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CATEGORY CARD
// ---------------------------------------------------------------------------

class _CategoryCard extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const _CategoryCard({
    required this.category,
    required this.isSelected,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final locked = category.isLocked;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: locked ? const Color(0xFFF5F5F5) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? category.color.withOpacity(0.35)
                : Colors.black.withOpacity(0.08),
            blurRadius: isSelected ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: locked
              ? const Color(0xFFE0E0E0)
              : isSelected
              ? category.color
              : Colors.transparent,
          width: 2.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // ── İkon kutusu ──
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(locked ? 0.06 : 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    locked ? Icons.lock_rounded : category.icon,
                    color: locked
                        ? category.color.withOpacity(0.4)
                        : category.color,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),

                // ── İsim + öğe sayısı / fiyat ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: locked
                              ? const Color(0xFF9E9E9E)
                              : const Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 3),
                      if (locked)
                        Row(
                          children: [
                            Icon(Icons.lock_outline_rounded,
                                size: 12,
                                color: category.color.withOpacity(0.7)),
                            const SizedBox(width: 4),
                            Text(
                              '₺${category.priceTL.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: category.color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Icon(
                              category.hasSubcategories
                                  ? Icons.account_tree_rounded
                                  : Icons.layers_rounded,
                              size: 13,
                              color: category.color.withOpacity(0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              category.hasSubcategories
                                  ? '${category.subcategories.length} alt kategori'
                                  : '${category.items.length} öğe',
                              style: TextStyle(
                                fontSize: 12,
                                color: category.color.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // ── Sağ: kilit butonu veya favori + seçim ──
                if (locked)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: category.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Satın Al',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: onFavorite,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                            child: Icon(
                              category.isFavorite
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              key: ValueKey(category.isFavorite),
                              color: category.isFavorite
                                  ? category.color
                                  : const Color(0xFFCCCCCC),
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: category.color,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PURCHASE SHEET — Ana kategori satın alma
// ---------------------------------------------------------------------------

class _PurchaseSheet extends StatefulWidget {
  final Category category;
  final VoidCallback onPurchaseSuccess;

  const _PurchaseSheet({
    required this.category,
    required this.onPurchaseSuccess,
  });

  @override
  State<_PurchaseSheet> createState() => _PurchaseSheetState();
}

class _PurchaseSheetState extends State<_PurchaseSheet> {
  bool _isLoading = false;

  Future<void> _purchase() async {
    final productId = IAPProducts.productIdForCategory(widget.category.id);
    if (productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ürün bulunamadı.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final iap = IAPService();
      final product =
          iap.products.where((p) => p.id == productId).firstOrNull;
      if (product == null) throw Exception('Ürün App Store\'dan yüklenemedi.');
      await iap.buyProduct(product);
      if (mounted) Navigator.pop(context);
      widget.onPurchaseSuccess();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Satın alma hatası: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _isLoading = true);
    try {
      await IAPService().restorePurchases();
      if (mounted) {
        Navigator.pop(context);
        widget.onPurchaseSuccess();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore hatası: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        top: 16,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: cat.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(cat.icon, color: cat.color, size: 36),
          ),
          const SizedBox(height: 16),

          Text(
            cat.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            cat.hasSubcategories
                ? '${cat.subcategories.length} alt kategori içerir'
                : '${cat.items.length} kelime içerir',
            style: const TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cat.color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cat.color.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tek seferlik satın alma',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  '₺${cat.priceTL.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: cat.color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _purchase,
              style: ElevatedButton.styleFrom(
                backgroundColor: cat.color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
                  : Text(
                '₺${cat.priceTL.toStringAsFixed(2)} — Satın Al',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 10),

          TextButton(
            onPressed: _isLoading ? null : _restore,
            child: const Text(
              'Önceki satın almayı geri yükle',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF9E9E9E),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SUB PURCHASE SHEET — Alt kategori satın alma (₺10)
// ---------------------------------------------------------------------------

class _SubPurchaseSheet extends StatefulWidget {
  final Category category;
  final Subcategory subcategory;
  final VoidCallback onPurchaseSuccess;

  const _SubPurchaseSheet({
    required this.category,
    required this.subcategory,
    required this.onPurchaseSuccess,
  });

  @override
  State<_SubPurchaseSheet> createState() => _SubPurchaseSheetState();
}

class _SubPurchaseSheetState extends State<_SubPurchaseSheet> {
  bool _isLoading = false;

  Future<void> _purchase() async {
    final productId =
    IAPProducts.productIdForSubcategory(widget.subcategory.id);
    if (productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ürün bulunamadı.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final iap = IAPService();
      final product =
          iap.products.where((p) => p.id == productId).firstOrNull;
      if (product == null) throw Exception('Ürün App Store\'dan yüklenemedi.');
      await iap.buyProduct(product);
      if (mounted) Navigator.pop(context);
      widget.onPurchaseSuccess();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Satın alma hatası: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
    final sub = widget.subcategory;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        top: 16,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: cat.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(cat.icon, color: cat.color, size: 36),
          ),
          const SizedBox(height: 16),

          Text(
            sub.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            cat.name,
            style: TextStyle(
              fontSize: 14,
              color: cat.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${sub.items.length} kelime · ${sub.hints.length} ipucu',
            style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cat.color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cat.color.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tek seferlik satın alma',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  '₺10,00',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: cat.color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _purchase,
              style: ElevatedButton.styleFrom(
                backgroundColor: cat.color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
                  : const Text(
                '₺10,00 — Satın Al',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SUBCATEGORY BOTTOM SHEET
// ---------------------------------------------------------------------------

class _SubcategorySheet extends StatefulWidget {
  final Category category;
  final void Function(Subcategory) onSelect;
  final Set<String> selectedSubIds;
  final void Function(Subcategory) onUnlockSub;

  const _SubcategorySheet({
    required this.category,
    required this.onSelect,
    required this.selectedSubIds,
    required this.onUnlockSub,
  });

  @override
  State<_SubcategorySheet> createState() => _SubcategorySheetState();
}

class _SubcategorySheetState extends State<_SubcategorySheet> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.selectedSubIds);
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cat.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(cat.icon, color: cat.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        _selected.isEmpty
                            ? 'Alt kategori seçin'
                            : '${_selected.length} seçildi',
                        style: TextStyle(
                          fontSize: 12,
                          color: _selected.isEmpty
                              ? const Color(0xFF9E9E9E)
                              : cat.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 18, color: Color(0xFF757575)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.55,
            ),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              shrinkWrap: true,
              itemCount: cat.subcategories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final sub = cat.subcategories[i];
                final isSelected = _selected.contains(sub.id);
                final isLocked = !sub.isUnlocked;

                return _SubcategoryItem(
                  subcategory: sub,
                  categoryColor: cat.color,
                  categoryIcon: cat.icon,
                  isSelected: isSelected,
                  isLocked: isLocked,
                  onTap: () {
                    if (isLocked) {
                      widget.onUnlockSub(sub);
                      return;
                    }
                    setState(() {
                      if (isSelected) {
                        _selected.remove(sub.id);
                      } else {
                        _selected.add(sub.id);
                      }
                    });
                    widget.onSelect(sub);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cat.color,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _selected.isEmpty
                      ? 'Kapat'
                      : 'Tamam (${_selected.length} seçili)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubcategoryItem extends StatelessWidget {
  final Subcategory subcategory;
  final Color categoryColor;
  final IconData categoryIcon;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onTap;

  const _SubcategoryItem({
    required this.subcategory,
    required this.categoryColor,
    required this.categoryIcon,
    required this.isSelected,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      height: 72,
      decoration: BoxDecoration(
        color: isLocked
            ? const Color(0xFFF9F9F9)
            : isSelected
            ? categoryColor
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLocked
              ? const Color(0xFFE8E8E8)
              : isSelected
              ? categoryColor
              : const Color(0xFFEEEEEE),
          width: isSelected ? 0 : 1.5,
        ),
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: categoryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isLocked
                        ? const Color(0xFFEEEEEE)
                        : isSelected
                        ? Colors.white.withOpacity(0.2)
                        : categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isLocked ? Icons.lock_rounded : categoryIcon,
                    color: isLocked
                        ? const Color(0xFFBBBBBB)
                        : isSelected
                        ? Colors.white
                        : categoryColor,
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
                        subcategory.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isLocked
                              ? const Color(0xFF9E9E9E)
                              : isSelected
                              ? Colors.white
                              : const Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isLocked
                            ? '₺10,00 · Kilidi Aç'
                            : '${subcategory.items.length} kelime · ${subcategory.hints.length} ipucu',
                        style: TextStyle(
                          fontSize: 12,
                          color: isLocked
                              ? categoryColor
                              : isSelected
                              ? Colors.white.withOpacity(0.75)
                              : const Color(0xFF9E9E9E),
                          fontWeight: isLocked
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLocked)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: categoryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '₺10',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else if (isSelected)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 16),
                  )
                else
                  Icon(Icons.add_rounded,
                      color: categoryColor.withOpacity(0.5), size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// START GAME BUTTON
// ---------------------------------------------------------------------------

class _StartGameButton extends StatelessWidget {
  final int selectedCount;
  final int totalItems;
  final VoidCallback onPressed;

  const _StartGameButton({
    required this.selectedCount,
    required this.totalItems,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFE91E63),
              elevation: 4,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_arrow_rounded, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Oyunu Başlat  ·  $selectedCount kategori  ·  $totalItems öğe',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// EMPTY STATE
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  final CategoryFilter filter;

  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final isFav = filter == CategoryFilter.favorites;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFav ? Icons.star_border_rounded : Icons.search_off_rounded,
            size: 64,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            isFav ? 'Henüz favori yok' : 'Kategori bulunamadı',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isFav
                ? 'Kategorilerdeki ⭐ ikonuna tıklayın'
                : 'Farklı bir arama deneyin',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// HELPER WIDGET
// ---------------------------------------------------------------------------

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  const _CircleBtn({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: active
              ? Colors.white.withOpacity(0.35)
              : Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}