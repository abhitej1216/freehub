import '../../core/constants/database_constants.dart';
import '../database/database_helper.dart';
import '../models/category_model.dart';
import 'package:sqflite/sqflite.dart';

class CategoryLocalDatasource {
  final DatabaseHelper _db;

  CategoryLocalDatasource(this._db);

  Future<List<CategoryModel>> getAllCategories() async {
    final results = await _db.rawQuery('''
      SELECT c.*,
        COUNT(w.${DatabaseConstants.colId}) as website_count
      FROM ${DatabaseConstants.tableCategories} c
      LEFT JOIN ${DatabaseConstants.tableWebsites} w
        ON c.${DatabaseConstants.colCatId} = w.${DatabaseConstants.colCategoryId}
      WHERE c.${DatabaseConstants.colParentCategoryId} IS NULL
      GROUP BY c.${DatabaseConstants.colCatId}
      ORDER BY c.${DatabaseConstants.colCatName} ASC
    ''');
    return results.map((m) => CategoryModel.fromMap(m)).toList();
  }

  Future<CategoryModel?> getById(int id) async {
    final results = await _db.rawQuery('''
      SELECT c.*,
        COUNT(w.${DatabaseConstants.colId}) as website_count
      FROM ${DatabaseConstants.tableCategories} c
      LEFT JOIN ${DatabaseConstants.tableWebsites} w
        ON c.${DatabaseConstants.colCatId} = w.${DatabaseConstants.colCategoryId}
      WHERE c.${DatabaseConstants.colCatId} = ?
      GROUP BY c.${DatabaseConstants.colCatId}
    ''', [id]);
    if (results.isEmpty) return null;
    return CategoryModel.fromMap(results.first);
  }

  Future<CategoryModel?> getByName(String name) async {
    final results = await _db.rawQuery('''
      SELECT c.*, 0 as website_count
      FROM ${DatabaseConstants.tableCategories} c
      WHERE LOWER(c.${DatabaseConstants.colCatName}) = LOWER(?)
    ''', [name]);
    if (results.isEmpty) return null;
    return CategoryModel.fromMap(results.first);
  }

  Future<List<CategoryModel>> getSubcategories(int parentId) async {
    final results = await _db.rawQuery('''
      SELECT c.*,
        COUNT(w.${DatabaseConstants.colId}) as website_count
      FROM ${DatabaseConstants.tableCategories} c
      LEFT JOIN ${DatabaseConstants.tableWebsites} w
        ON c.${DatabaseConstants.colCatId} = w.${DatabaseConstants.colCategoryId}
      WHERE c.${DatabaseConstants.colParentCategoryId} = ?
      GROUP BY c.${DatabaseConstants.colCatId}
      ORDER BY c.${DatabaseConstants.colCatName} ASC
    ''', [parentId]);
    return results.map((m) => CategoryModel.fromMap(m)).toList();
  }

  Future<int> insert(CategoryModel model) async {
    return _db.insert(
      DatabaseConstants.tableCategories,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<int> update(CategoryModel model) async {
    return _db.update(
      DatabaseConstants.tableCategories,
      model.toMap(),
      where: '${DatabaseConstants.colCatId} = ?',
      whereArgs: [model.id],
    );
  }

  Future<int> delete(int id) async {
    return _db.delete(
      DatabaseConstants.tableCategories,
      where: '${DatabaseConstants.colCatId} = ?',
      whereArgs: [id],
    );
  }

  Future<bool> nameExists(String name) async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) FROM ${DatabaseConstants.tableCategories} WHERE LOWER(${DatabaseConstants.colCatName}) = LOWER(?)',
      [name],
    );
    return (result.first.values.first as int? ?? 0) > 0;
  }

  Future<void> insertBatch(List<CategoryModel> models) async {
    await _db.transaction((txn) async {
      for (final model in models) {
        await txn.insert(
          DatabaseConstants.tableCategories,
          model.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    });
  }
}
