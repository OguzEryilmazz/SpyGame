import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource _dataSource;

  CategoryRepositoryImpl(this._dataSource);

  static const _favKey = 'favorites';

  @override
  Future<List<Category>> getCategories() async {
    final dtos = await _dataSource.loadCategories();
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<void> saveFavorite(String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_favKey) ?? [];
    if (!current.contains(categoryId)) {
      current.add(categoryId);
      await prefs.setStringList(_favKey, current);
    }
  }

  @override
  Future<void> removeFavorite(String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_favKey) ?? [];
    current.remove(categoryId);
    await prefs.setStringList(_favKey, current);
  }

  @override
  Future<List<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favKey) ?? [];
  }
}
