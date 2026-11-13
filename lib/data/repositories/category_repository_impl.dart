import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDatasource _categoryDs;

  CategoryRepositoryImpl(this._categoryDs);

  @override
  Future<List<CategoryEntity>> getAllCategories() async {
    return _categoryDs.getAllCategories();
  }

  @override
  Future<CategoryEntity?> getById(int id) async {
    return _categoryDs.getById(id);
  }

  @override
  Future<CategoryEntity?> getByName(String name) async {
    return _categoryDs.getByName(name);
  }

  @override
  Future<List<CategoryEntity>> getSubcategories(int parentId) async {
    return _categoryDs.getSubcategories(parentId);
  }

  @override
  Future<CategoryEntity> addCategory(CategoryEntity category) async {
    final model = CategoryModel.fromEntity(category);
    final id = await _categoryDs.insert(model);
    return model.copyWith(id: id);
  }

  @override
  Future<CategoryEntity> updateCategory(CategoryEntity category) async {
    final model = CategoryModel.fromEntity(category);
    await _categoryDs.update(model);
    return model;
  }

  @override
  Future<void> deleteCategory(int id) async {
    await _categoryDs.delete(id);
  }

  @override
  Future<bool> nameExists(String name) async {
    return _categoryDs.nameExists(name);
  }

  @override
  Future<void> insertBatch(List<CategoryEntity> categories) async {
    final models =
        categories.map((c) => CategoryModel.fromEntity(c)).toList();
    await _categoryDs.insertBatch(models);
  }
}
