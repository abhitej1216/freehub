import 'package:sqflite/sqflite.dart';
import '../entities/website_entity.dart';

abstract class WebsiteRepository {
  Future<List<WebsiteEntity>> getAllWebsites({int? limit, int? offset});
  Future<List<WebsiteEntity>> getRecentlyAdded({int limit = 10});
  Future<List<WebsiteEntity>> getBookmarked();
  Future<List<WebsiteEntity>> getByCategory(int categoryId);
  Future<WebsiteEntity?> getById(int id);
  Future<WebsiteEntity?> getByUrl(String url);
  Future<WebsiteEntity?> getByUrlCaseInsensitive(String url);
  Future<List<WebsiteEntity>> search(
    String query, {
    String? websiteType,
    bool? isBookmarked,
    bool? isCustom,
    bool? recentlyAdded,
    int? categoryId,
    int? limit,
    int? offset,
  });
  Future<WebsiteEntity> addWebsite(WebsiteEntity website);
  Future<WebsiteEntity> updateWebsite(WebsiteEntity website);
  Future<void> deleteWebsite(int id);
  Future<WebsiteEntity> toggleBookmark(int id);
  Future<void> recordVisit(int websiteId);
  Future<List<WebsiteEntity>> getRecentlyVisited({int limit = 10});
  Future<List<WebsiteEntity>> getMostVisited({int limit = 10});
  Future<int> getTotalCount();
  Future<bool> urlExists(String url);
  Future<void> insertBatch(List<WebsiteEntity> websites);

  /// Transaction-aware variants used by the import executor so the whole
  /// catalog import runs in a single SQLite transaction (fast + atomic).
  /// sqflite only routes operations through the `txn` object passed to
  /// `db.transaction()`; calling the database directly inside the callback
  /// opens a separate connection that is not part of the transaction.
  Future<int> addWebsiteTx(Transaction txn, WebsiteEntity website);
  Future<int> updateWebsiteTx(Transaction txn, WebsiteEntity website);
  Future<WebsiteEntity?> getByUrlCaseInsensitiveTx(
      Transaction txn, String url);
}
