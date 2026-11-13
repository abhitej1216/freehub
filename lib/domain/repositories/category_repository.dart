import '../entities/category_entity.dart';

abstract class CategoryRepository {
  Future<List<CategoryEntity>> getAllCategories();
  Future<CategoryEntity?> getById(int id);
  Future<CategoryEntity?> getByName(String name);
  Future<List<CategoryEntity>> getSubcategories(int parentId);
  Future<CategoryEntity> addCategory(CategoryEntity category);
  Future<CategoryEntity> updateCategory(CategoryEntity category);
  Future<void> deleteCategory(int id);
  Future<bool> nameExists(String name);
  Future<void> insertBatch(List<CategoryEntity> categories);
}
