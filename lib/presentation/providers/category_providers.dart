import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category_entity.dart';
import 'database_providers.dart';

class CategoriesNotifier extends StateNotifier<AsyncValue<List<CategoryEntity>>> {
  final Ref _ref;

  CategoriesNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(categoryRepositoryProvider);
      final categories = await repo.getAllCategories();
      state = AsyncValue.data(categories);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<CategoryEntity?> addCategory({
    required String name,
    String? description,
    String? icon,
    int? parentCategoryId,
  }) async {
    try {
      final repo = _ref.read(categoryRepositoryProvider);
      final exists = await repo.nameExists(name);
      if (exists) {
        throw Exception('Category "$name" already exists');
      }

      final newCategory = CategoryEntity(
        name: name,
        description: description,
        icon: icon ?? 'folder',
        parentCategoryId: parentCategoryId,
      );

      final created = await repo.addCategory(newCategory);
      await loadCategories();
      return created;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCategory(CategoryEntity category) async {
    try {
      final repo = _ref.read(categoryRepositoryProvider);
      await repo.updateCategory(category);
      await loadCategories();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      final repo = _ref.read(categoryRepositoryProvider);
      await repo.deleteCategory(id);
      await loadCategories();
    } catch (e) {
      rethrow;
    }
  }
}

final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, AsyncValue<List<CategoryEntity>>>(
        (ref) {
  return CategoriesNotifier(ref);
});

final popularCategoriesProvider = Provider<List<CategoryEntity>>((ref) {
  final categoriesState = ref.watch(categoriesProvider);
  return categoriesState.maybeWhen(
    data: (categories) {
      final list = List<CategoryEntity>.from(categories);
      list.sort((a, b) => b.websiteCount.compareTo(a.websiteCount));
      return list.take(8).toList();
    },
    orElse: () => [],
  );
});

final categoryByIdProvider =
    Provider.family<CategoryEntity?, int>((ref, categoryId) {
  final categoriesState = ref.watch(categoriesProvider);
  return categoriesState.maybeWhen(
    data: (categories) =>
        categories.where((c) => c.id == categoryId).firstOrNull,
    orElse: () => null,
  );
});
