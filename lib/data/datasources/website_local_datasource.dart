import 'package:sqflite/sqflite.dart';
import '../../core/constants/database_constants.dart';
import '../database/database_helper.dart';
import '../models/website_model.dart';

class WebsiteLocalDatasource {
  final DatabaseHelper _db;

  WebsiteLocalDatasource(this._db);

  Future<List<WebsiteModel>> getAllWebsites({
    int? limit,
    int? offset,
    String? orderBy,
  }) async {
    final results = await _db.rawQuery('''
      SELECT w.*, c.${DatabaseConstants.colCatName} as category_name
      FROM ${DatabaseConstants.tableWebsites} w
      LEFT JOIN ${DatabaseConstants.tableCategories} c
        ON w.${DatabaseConstants.colCategoryId} = c.${DatabaseConstants.colCatId}
      ORDER BY ${orderBy ?? 'w.${DatabaseConstants.colDateAdded} DESC'}
      ${limit != null ? 'LIMIT $limit' : ''}
      ${offset != null ? 'OFFSET $offset' : ''}
    ''');
    return results.map((m) => WebsiteModel.fromMap(m)).toList();
  }

  Future<List<WebsiteModel>> getRecentlyAdded({int limit = 10}) async {
    return getAllWebsites(
      limit: limit,
      orderBy: 'w.${DatabaseConstants.colDateAdded} DESC',
    );
  }

  Future<List<WebsiteModel>> getBookmarked() async {
    final results = await _db.rawQuery('''
      SELECT w.*, c.${DatabaseConstants.colCatName} as category_name
      FROM ${DatabaseConstants.tableWebsites} w
      LEFT JOIN ${DatabaseConstants.tableCategories} c
        ON w.${DatabaseConstants.colCategoryId} = c.${DatabaseConstants.colCatId}
      WHERE w.${DatabaseConstants.colIsBookmarked} = 1
      ORDER BY w.${DatabaseConstants.colLastUpdated} DESC
    ''');
    return results.map((m) => WebsiteModel.fromMap(m)).toList();
  }

  Future<List<WebsiteModel>> getByCategory(int categoryId) async {
    final results = await _db.rawQuery('''
      SELECT w.*, c.${DatabaseConstants.colCatName} as category_name
      FROM ${DatabaseConstants.tableWebsites} w
      LEFT JOIN ${DatabaseConstants.tableCategories} c
        ON w.${DatabaseConstants.colCategoryId} = c.${DatabaseConstants.colCatId}
      WHERE w.${DatabaseConstants.colCategoryId} = ?
      ORDER BY w.${DatabaseConstants.colName} ASC
    ''', [categoryId]);
    return results.map((m) => WebsiteModel.fromMap(m)).toList();
  }

  Future<WebsiteModel?> getById(int id) async {
    final results = await _db.rawQuery('''
      SELECT w.*, c.${DatabaseConstants.colCatName} as category_name
      FROM ${DatabaseConstants.tableWebsites} w
      LEFT JOIN ${DatabaseConstants.tableCategories} c
        ON w.${DatabaseConstants.colCategoryId} = c.${DatabaseConstants.colCatId}
      WHERE w.${DatabaseConstants.colId} = ?
    ''', [id]);
    if (results.isEmpty) return null;
    return WebsiteModel.fromMap(results.first);
  }

  Future<WebsiteModel?> getByUrl(String url) async {
    final results = await _db.rawQuery('''
      SELECT w.*, c.${DatabaseConstants.colCatName} as category_name
      FROM ${DatabaseConstants.tableWebsites} w
      LEFT JOIN ${DatabaseConstants.tableCategories} c
        ON w.${DatabaseConstants.colCategoryId} = c.${DatabaseConstants.colCatId}
      WHERE w.${DatabaseConstants.colUrl} = ?
    ''', [url]);
    if (results.isEmpty) return null;
    return WebsiteModel.fromMap(results.first);
  }

  Future<List<WebsiteModel>> search(
    String query, {
    String? websiteType,
    bool? isBookmarked,
    bool? isCustom,
    bool? recentlyAdded,
    int? categoryId,
    int? limit,
    int? offset,
  }) async {
    final conditions = <String>[];
    final args = <dynamic>[];

    if (query.isNotEmpty) {
      conditions.add('''
        (w.${DatabaseConstants.colName} LIKE ?
        OR w.${DatabaseConstants.colUrl} LIKE ?
        OR w.${DatabaseConstants.colDescription} LIKE ?
        OR w.${DatabaseConstants.colSubcategory} LIKE ?
        OR w.${DatabaseConstants.colTags} LIKE ?
        OR c.${DatabaseConstants.colCatName} LIKE ?)
      ''');
      final like = '%$query%';
      args.addAll([like, like, like, like, like, like]);
    }

    if (websiteType != null) {
      conditions.add('w.${DatabaseConstants.colWebsiteType} = ?');
      args.add(websiteType);
    }

    if (isBookmarked != null) {
      conditions.add('w.${DatabaseConstants.colIsBookmarked} = ?');
      args.add(isBookmarked ? 1 : 0);
    }

    if (isCustom != null) {
      conditions.add('w.${DatabaseConstants.colSource} = ?');
      args.add(isCustom ? 'CUSTOM' : 'FMHY');
    }

    if (categoryId != null) {
      conditions.add('w.${DatabaseConstants.colCategoryId} = ?');
      args.add(categoryId);
    }

    if (recentlyAdded == true) {
      conditions.add('''
        w.${DatabaseConstants.colDateAdded} >= datetime('now', '-7 days')
      ''');
    }

    final whereClause =
        conditions.isNotEmpty ? 'WHERE ${conditions.join(' AND ')}' : '';
    final limitClause = limit != null ? 'LIMIT $limit' : '';
    final offsetClause = offset != null ? 'OFFSET $offset' : '';

    final sql = '''
      SELECT w.*, c.${DatabaseConstants.colCatName} as category_name
      FROM ${DatabaseConstants.tableWebsites} w
      LEFT JOIN ${DatabaseConstants.tableCategories} c
        ON w.${DatabaseConstants.colCategoryId} = c.${DatabaseConstants.colCatId}
      $whereClause
      ORDER BY w.${DatabaseConstants.colName} ASC
      $limitClause $offsetClause
    ''';

    final results = await _db.rawQuery(sql, args);
    return results.map((m) => WebsiteModel.fromMap(m)).toList();
  }

  Future<int> insert(WebsiteModel model) async {
    return _db.insert(
      DatabaseConstants.tableWebsites,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<int> update(WebsiteModel model) async {
    return _db.update(
      DatabaseConstants.tableWebsites,
      model.toMap(),
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [model.id],
    );
  }

  Future<int> delete(int id) async {
    return _db.delete(
      DatabaseConstants.tableWebsites,
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  Future<int> toggleBookmark(int id, bool isBookmarked) async {
    final now = DateTime.now().toUtc().toIso8601String();
    return _db.update(
      DatabaseConstants.tableWebsites,
      {
        DatabaseConstants.colIsBookmarked: isBookmarked ? 1 : 0,
        DatabaseConstants.colLastUpdated: now,
      },
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  Future<int> getTotalCount() async {
    final result = await _db.rawQuery(
        'SELECT COUNT(*) FROM ${DatabaseConstants.tableWebsites}');
    return result.first.values.first as int? ?? 0;
  }

  Future<bool> urlExists(String url) async {
    final result = await _db.rawQuery(
        'SELECT COUNT(*) FROM ${DatabaseConstants.tableWebsites} WHERE ${DatabaseConstants.colUrl} = ?',
        [url]);
    return (result.first.values.first as int? ?? 0) > 0;
  }

  Future<void> insertBatch(List<WebsiteModel> models) async {
    await _db.transaction((txn) async {
      for (final model in models) {
        await txn.insert(
          DatabaseConstants.tableWebsites,
          model.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    });
  }

  Future<List<WebsiteModel>> getRecentlyVisited({int limit = 10}) async {
    final results = await _db.rawQuery('''
      SELECT DISTINCT w.*, c.${DatabaseConstants.colCatName} as category_name,
        vh.${DatabaseConstants.colVisitedAt} as last_visit
      FROM ${DatabaseConstants.tableWebsites} w
      INNER JOIN ${DatabaseConstants.tableVisitHistory} vh
        ON w.${DatabaseConstants.colId} = vh.${DatabaseConstants.colWebsiteId}
      LEFT JOIN ${DatabaseConstants.tableCategories} c
        ON w.${DatabaseConstants.colCategoryId} = c.${DatabaseConstants.colCatId}
      GROUP BY w.${DatabaseConstants.colId}
      ORDER BY MAX(vh.${DatabaseConstants.colVisitedAt}) DESC
      LIMIT ?
    ''', [limit]);
    return results.map((m) => WebsiteModel.fromMap(m)).toList();
  }
}
