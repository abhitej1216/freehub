import '../../core/constants/database_constants.dart';
import '../database/database_helper.dart';

class VisitHistoryDatasource {
  final DatabaseHelper _db;

  VisitHistoryDatasource(this._db);

  Future<void> addVisit(int websiteId) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _db.insert(
      DatabaseConstants.tableVisitHistory,
      {
        DatabaseConstants.colWebsiteId: websiteId,
        DatabaseConstants.colVisitedAt: now,
      },
    );
  }

  Future<void> clearAll() async {
    await _db.clearVisitHistory();
  }

  Future<int> getVisitCount(int websiteId) async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) FROM ${DatabaseConstants.tableVisitHistory} WHERE ${DatabaseConstants.colWebsiteId} = ?',
      [websiteId],
    );
    return result.first.values.first as int? ?? 0;
  }
}
