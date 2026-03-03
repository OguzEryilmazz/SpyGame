import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/category_dto.dart';

/// Loads category data from the bundled JSON asset.
/// Uses rootBundle — no network, no Dio needed for local assets.
class CategoryLocalDataSource {
  static const _assetPath = 'assets/data/categories.json';

  Future<CategoriesRootDto> loadRoot() async {
    final jsonStr = await rootBundle.loadString(_assetPath);
    final decoded = json.decode(jsonStr) as Map<String, dynamic>;
    return CategoriesRootDto.fromJson(decoded);
  }

  Future<List<CategoryDto>> loadCategories() async {
    final root = await loadRoot();
    return root.categories;
  }
}
