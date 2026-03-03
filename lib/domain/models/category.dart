import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';

// ── Sub-category ──────────────────────────────────────────────────────────────
// Used both for:
//   • "hasSubcategories: true" entries  (athletes, singers, actors, youtubers)
//   • Flat categories are also wrapped as a single SubCategory internally

@freezed
class SubCategory with _$SubCategory {
  const SubCategory._();

  const factory SubCategory({
    required String id,
    required String name,

    /// The word list (JSON key: "items")
    @Default([]) List<String> items,

    /// Spy hints shown when hintsEnabled is true
    @Default([]) List<String> hints,

    /// Can be unlocked by watching a rewarded ad
    @Default(false) bool unlockedByAd,

    /// Currently unlocked (by ad or purchase)
    @Default(false) bool isUnlocked,
  }) = _SubCategory;

  bool get isPlayable => items.isNotEmpty;
}

// ── Category ──────────────────────────────────────────────────────────────────

@freezed
class Category with _$Category {
  const Category._();

  const factory Category({
    required String id,
    required String name,

    /// Material icon name string (e.g. "work", "restaurant")
    @Default('category') String iconName,

    /// Hex color string (e.g. "#2196F3")
    @Default('#607D8B') String colorHex,

    /// Requires purchase to play
    @Default(false) bool isLocked,

    /// Price in Turkish Lira; 0.0 means free
    @Default(0.0) double priceTL,

    /// True when this category uses subcategories instead of a flat item list
    @Default(false) bool hasSubcategories,

    /// Flat item list — only populated when hasSubcategories is false
    @Default([]) List<String> items,

    /// Flat hint list — only populated when hasSubcategories is false
    @Default([]) List<String> hints,

    /// Populated when hasSubcategories is true
    @Default([]) List<SubCategory> subcategories,
  }) = _Category;

  /// Returns playable sub-categories: either the nested list,
  /// or a single synthetic SubCategory built from the flat items/hints.
  List<SubCategory> get playableSubCategories {
    if (hasSubcategories) return subcategories;
    return [
      SubCategory(
        id: id,
        name: name,
        items: items,
        hints: hints,
        isUnlocked: !isLocked,
      ),
    ];
  }
}
