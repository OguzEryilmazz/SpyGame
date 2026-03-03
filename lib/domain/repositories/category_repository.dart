import '../models/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories();
  Future<void> saveFavorite(String categoryId);
  Future<void> removeFavorite(String categoryId);
  Future<List<String>> getFavoriteIds();
}
