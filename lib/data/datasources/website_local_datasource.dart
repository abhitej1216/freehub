import 'package:sqflite/sqflite.dart';
import '../../core/constants/database_constants.dart';
import '../database/database_helper.dart';
import '../models/website_model.dart';

class WebsiteLocalDatasource {
  final DatabaseHelper _db;

  WebsiteLocalDatasource(this._db);

  Future<List<WebsiteModel>> getAllWebsites({int? limit, int? offset}) async {
    final results = await _db.query(
      DatabaseConstants.tableWebsites,
      orderBy: '${DatabaseConstants.colDateAdded} DESC',
      limit: limit,
      offset: offset,
    );
    return results.map((m) => WebsiteModel.fromMap(m)).toList();
  }

  Future<List<WebsiteModel>> getRecentlyAdded({int limit = 10}) async {
    final results = await _db.query(
      DatabaseConstants.tableWebsites,
      orderBy: '${DatabaseConstants.colDateAdded} DESC',
      limit: limit,
    );
    return results.map((m) => WebsiteModel.fromMap(m)).toList();
  }

  Future<List<WebsiteModel>> getBookmarked() async {
    final results = await _db.query(
      DatabaseConstants.tableWebsites,
      where: '${DatabaseConstants.colIsBookmarked} = ?',
      whereArgs: [1],
      orderBy: '${DatabaseConstants.colDateAdded} DESC',
    );
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
    final results = await _db.query(
      DatabaseConstants.tableWebsites,
      where: '${DatabaseConstants.colUrl} = ?',
      whereArgs: [url],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return WebsiteModel.fromMap(results.first);
  }

  /// Case-insensitive URL lookup so imports match the preview and catch
  /// duplicate URLs that differ only by scheme/domain casing.
  Future<WebsiteModel?> getByUrlCaseInsensitive(String url) async {
    final results = await _db.query(
      DatabaseConstants.tableWebsites,
      where: 'LOWER(TRIM(${DatabaseConstants.colUrl})) = LOWER(TRIM(?))',
      whereArgs: [url],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return WebsiteModel.fromMap(results.first);
  }

  /// Transaction-aware variant of [getByUrlCaseInsensitive] used during
  /// batch imports so queries share the transaction connection.
  Future<WebsiteModel?> getByUrlCaseInsensitiveTx(
      Transaction txn, String url) async {
    final results = await txn.query(
      DatabaseConstants.tableWebsites,
      where: 'LOWER(TRIM(${DatabaseConstants.colUrl})) = LOWER(TRIM(?))',
      whereArgs: [url],
      limit: 1,
    );
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
    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (query.trim().isNotEmpty) {
      final q = '%${query.trim()}%';
      whereClauses.add('''
        (w.${DatabaseConstants.colName} LIKE ?
         OR w.${DatabaseConstants.colUrl} LIKE ?
         OR w.${DatabaseConstants.colDescription} LIKE ?
         OR w.${DatabaseConstants.colSubcategory} LIKE ?
         OR w.${DatabaseConstants.colTags} LIKE ?
         OR c.${DatabaseConstants.colCatName} LIKE ?)
      ''');
      whereArgs.addAll([q, q, q, q, q, q]);
    }

    if (websiteType != null) {
      whereClauses.add('w.${DatabaseConstants.colWebsiteType} = ?');
      whereArgs.add(websiteType);
    }

    if (isBookmarked != null) {
      whereClauses.add('w.${DatabaseConstants.colIsBookmarked} = ?');
      whereArgs.add(isBookmarked ? 1 : 0);
    }

    if (isCustom != null) {
      whereClauses.add('w.${DatabaseConstants.colSource} = ?');
      whereArgs.add(isCustom ? 'CUSTOM' : 'FMHY');
    }

    if (categoryId != null) {
      whereClauses.add('w.${DatabaseConstants.colCategoryId} = ?');
      whereArgs.add(categoryId);
    }

    final whereString =
        whereClauses.isNotEmpty ? 'WHERE ${whereClauses.join(' AND ')}' : '';

    final orderBy = recentlyAdded == true
        ? 'ORDER BY w.${DatabaseConstants.colDateAdded} DESC'
        : 'ORDER BY w.${DatabaseConstants.colName} ASC';

    final limitClause = limit != null ? 'LIMIT $limit' : '';
    final offsetClause = offset != null ? 'OFFSET $offset' : '';

    final rawSql = '''
      SELECT w.*, c.${DatabaseConstants.colCatName} as category_name
      FROM ${DatabaseConstants.tableWebsites} w
      LEFT JOIN ${DatabaseConstants.tableCategories} c
        ON w.${DatabaseConstants.colCategoryId} = c.${DatabaseConstants.colCatId}
      $whereString
      $orderBy
      $limitClause
      $offsetClause
    ''';

    final results = await _db.rawQuery(rawSql, whereArgs);
    return results.map((m) => WebsiteModel.fromMap(m)).toList();
  }

  Future<int> insert(WebsiteModel website) async {
    return _db.insert(
      DatabaseConstants.tableWebsites,
      website.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Transaction-aware variant of [insert] used during batch imports so all
  /// inserts share a single SQLite transaction (10-50x faster).
  Future<int> insertTx(Transaction txn, WebsiteModel website) async {
    return txn.insert(
      DatabaseConstants.tableWebsites,
      website.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<int> update(WebsiteModel website) async {
    return _db.update(
      DatabaseConstants.tableWebsites,
      website.toMap(),
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [website.id],
    );
  }

  /// Transaction-aware variant of [update] used during batch imports.
  Future<int> updateTx(Transaction txn, WebsiteModel website) async {
    return txn.update(
      DatabaseConstants.tableWebsites,
      website.toMap(),
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [website.id],
    );
  }

  Future<int> delete(int id) async {
    return _db.delete(
      DatabaseConstants.tableWebsites,
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  Future<int> toggleBookmark(int id, bool currentStatus) async {
    return _db.update(
      DatabaseConstants.tableWebsites,
      {DatabaseConstants.colIsBookmarked: currentStatus ? 0 : 1},
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  Future<int> getTotalCount() async {
    final result = await _db.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseConstants.tableWebsites}');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<bool> urlExists(String url) async {
    final result = await _db.rawQuery(
      'SELECT 1 FROM ${DatabaseConstants.tableWebsites} WHERE LOWER(${DatabaseConstants.colUrl}) = LOWER(?) LIMIT 1',
      [url.trim()],
    );
    return result.isNotEmpty;
  }

  Future<void> insertBatch(List<WebsiteModel> websites) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      for (final model in websites) {
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

  /// Websites ranked by total visit count (most visited first), ties broken
  /// alphabetically. Used by the "Most Visited" sort option.
  Future<List<WebsiteModel>> getMostVisited({int limit = 10}) async {
    final results = await _db.rawQuery('''
      SELECT w.*, c.${DatabaseConstants.colCatName} as category_name,
        COUNT(vh.${DatabaseConstants.colVisitId}) as visit_count
      FROM ${DatabaseConstants.tableWebsites} w
      LEFT JOIN ${DatabaseConstants.tableVisitHistory} vh
        ON w.${DatabaseConstants.colId} = vh.${DatabaseConstants.colWebsiteId}
      LEFT JOIN ${DatabaseConstants.tableCategories} c
        ON w.${DatabaseConstants.colCategoryId} = c.${DatabaseConstants.colCatId}
      GROUP BY w.${DatabaseConstants.colId}
      ORDER BY visit_count DESC, w.${DatabaseConstants.colName} ASC
      LIMIT ?
    ''', [limit]);
    return results.map((m) => WebsiteModel.fromMap(m)).toList();
  }
}
