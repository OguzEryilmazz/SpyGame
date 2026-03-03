import '../../domain/models/category.dart';

// ── Sub-category DTO ──────────────────────────────────────────────────────────

class SubCategoryDto {
  final String id;
  final String name;
  final List<String> items;
  final List<String> hints;
  final bool unlockedByAd;
  final bool isUnlocked;

  const SubCategoryDto({
    required this.id,
    required this.name,
    required this.items,
    required this.hints,
    required this.unlockedByAd,
    required this.isUnlocked,
  });

  factory SubCategoryDto.fromJson(Map<String, dynamic> json) {
    return SubCategoryDto(
      id: json['id'] as String,
      name: json['name'] as String,
      items: _parseStringList(json['items']),
      hints: _parseStringList(json['hints']),
      unlockedByAd: json['unlockedByAd'] as bool? ?? false,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
    );
  }

  SubCategory toDomain() => SubCategory(
        id: id,
        name: name,
        items: items,
        hints: hints,
        unlockedByAd: unlockedByAd,
        isUnlocked: isUnlocked,
      );
}

// ── Category DTO ──────────────────────────────────────────────────────────────

class CategoryDto {
  final String id;
  final String name;
  final String iconName;
  final String colorHex;
  final bool isLocked;
  final double priceTL;
  final bool hasSubcategories;

  /// Flat word list — only present when hasSubcategories is false
  final List<String> items;
  final List<String> hints;

  /// Nested sub-categories — only present when hasSubcategories is true
  final List<SubCategoryDto> subcategories;

  const CategoryDto({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorHex,
    required this.isLocked,
    required this.priceTL,
    required this.hasSubcategories,
    required this.items,
    required this.hints,
    required this.subcategories,
  });

  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    final hasSubs = json['hasSubcategories'] as bool? ?? false;
    return CategoryDto(
      id: json['id'] as String,
      name: json['name'] as String,
      iconName: json['iconName'] as String? ?? 'category',
      colorHex: json['colorHex'] as String? ?? '#607D8B',
      isLocked: json['isLocked'] as bool? ?? false,
      priceTL: (json['priceTL'] as num?)?.toDouble() ?? 0.0,
      hasSubcategories: hasSubs,
      items: hasSubs ? [] : _parseStringList(json['items']),
      hints: hasSubs ? [] : _parseStringList(json['hints']),
      subcategories: hasSubs
          ? (json['subcategories'] as List<dynamic>? ?? [])
              .map((e) => SubCategoryDto.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Category toDomain() => Category(
        id: id,
        name: name,
        iconName: iconName,
        colorHex: colorHex,
        isLocked: isLocked,
        priceTL: priceTL,
        hasSubcategories: hasSubcategories,
        items: items,
        hints: hints,
        subcategories: subcategories.map((s) => s.toDomain()).toList(),
      );
}

// ── Root DTO ──────────────────────────────────────────────────────────────────
// Parses the top-level { "version": 16, "categories": [...] } wrapper.

class CategoriesRootDto {
  final int version;
  final List<CategoryDto> categories;

  const CategoriesRootDto({required this.version, required this.categories});

  factory CategoriesRootDto.fromJson(Map<String, dynamic> json) {
    return CategoriesRootDto(
      version: json['version'] as int? ?? 0,
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((e) => CategoryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ── Helper ────────────────────────────────────────────────────────────────────

List<String> _parseStringList(dynamic value) {
  if (value == null) return [];
  return (value as List<dynamic>)
      .map((e) => e as String)
      .where((s) => s.isNotEmpty)   // drop blank entries (e.g. WWE has "")
      .toList();
}
