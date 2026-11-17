import 'package:sqflite/sqflite.dart';
import '../../domain/entities/website_entity.dart';
import '../../domain/repositories/website_repository.dart';
import '../datasources/website_local_datasource.dart';
import '../datasources/visit_history_datasource.dart';
import '../models/website_model.dart';
import '../../core/utils/date_utils.dart';

class WebsiteRepositoryImpl implements WebsiteRepository {
  final WebsiteLocalDatasource _websiteDs;
  final VisitHistoryDatasource _historyDs;

  WebsiteRepositoryImpl(this._websiteDs, this._historyDs);

  @override
  Future<List<WebsiteEntity>> getAllWebsites({int? limit, int? offset}) async {
    return _websiteDs.getAllWebsites(limit: limit, offset: offset);
  }

  @override
  Future<List<WebsiteEntity>> getRecentlyAdded({int limit = 10}) async {
    return _websiteDs.getRecentlyAdded(limit: limit);
  }

  @override
  Future<List<WebsiteEntity>> getBookmarked() async {
    return _websiteDs.getBookmarked();
  }

  @override
  Future<List<WebsiteEntity>> getByCategory(int categoryId) async {
    return _websiteDs.getByCategory(categoryId);
  }

  @override
  Future<WebsiteEntity?> getById(int id) async {
    return _websiteDs.getById(id);
  }

  @override
  Future<WebsiteEntity?> getByUrl(String url) async {
    return _websiteDs.getByUrl(url);
  }

  @override
  Future<List<WebsiteEntity>> search(
    String query, {
    String? websiteType,
    bool? isBookmarked,
    bool? isCustom,
    bool? recentlyAdded,
    int? categoryId,
    int? limit,
    int? offset,
  }) async {
    return _websiteDs.search(
      query,
      websiteType: websiteType,
      isBookmarked: isBookmarked,
      isCustom: isCustom,
      recentlyAdded: recentlyAdded,
      categoryId: categoryId,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<WebsiteEntity> addWebsite(WebsiteEntity website) async {
    final now = AppDateUtils.now();
    final model = WebsiteModel(
      name: website.name,
      url: website.url,
      description: website.description,
      categoryId: website.categoryId,
      categoryName: website.categoryName,
      subcategory: website.subcategory,
      faviconUrl: website.faviconUrl,
      tags: website.tags,
      websiteType: website.websiteType,
      source: website.source,
      isBookmarked: website.isBookmarked,
      dateAdded: now,
      lastUpdated: now,
    );
    final id = await _websiteDs.insert(model);
    if (id <= 0) {
      // ConflictAlgorithm.ignore returns 0 when the unique constraint fails
      throw Exception('A website with this URL already exists');
    }
    return model.copyWith(id: id);
  }

  @override
  Future<WebsiteEntity> updateWebsite(WebsiteEntity website) async {
    final now = AppDateUtils.now();
    final model =
        WebsiteModel.fromEntity(website.copyWith(lastUpdated: now));
    final count = await _websiteDs.update(model);
    if (count <= 0) {
      throw Exception('Failed to update website: entry not found');
    }
    return model;
  }

  @override
  Future<WebsiteEntity?> getByUrlCaseInsensitive(String url) async {
    return _websiteDs.getByUrlCaseInsensitive(url);
  }

  @override
  Future<int> addWebsiteTx(Transaction txn, WebsiteEntity website) async {
    final now = AppDateUtils.now();
    final model = WebsiteModel(
      name: website.name,
      url: website.url,
      description: website.description,
      categoryId: website.categoryId,
      categoryName: website.categoryName,
      subcategory: website.subcategory,
      faviconUrl: website.faviconUrl,
      tags: website.tags,
      websiteType: website.websiteType,
      source: website.source,
      isBookmarked: website.isBookmarked,
      dateAdded: now,
      lastUpdated: now,
    );
    return _websiteDs.insertTx(txn, model);
  }

  @override
  Future<int> updateWebsiteTx(Transaction txn, WebsiteEntity website) async {
    final now = AppDateUtils.now();
    final model =
        WebsiteModel.fromEntity(website.copyWith(lastUpdated: now));
    return _websiteDs.updateTx(txn, model);
  }

  @override
  Future<WebsiteEntity?> getByUrlCaseInsensitiveTx(
      Transaction txn, String url) async {
    return _websiteDs.getByUrlCaseInsensitiveTx(txn, url);
  }

  @override
  Future<void> deleteWebsite(int id) async {
    await _websiteDs.delete(id);
  }

  @override
  Future<WebsiteEntity> toggleBookmark(int id) async {
    final website = await _websiteDs.getById(id);
    if (website == null) throw Exception('Website not found');
    await _websiteDs.toggleBookmark(id, website.isBookmarked);
    return website.copyWith(isBookmarked: !website.isBookmarked);
  }

  @override
  Future<void> recordVisit(int websiteId) async {
    await _historyDs.addVisit(websiteId);
  }

  @override
  Future<List<WebsiteEntity>> getRecentlyVisited({int limit = 10}) async {
    return _websiteDs.getRecentlyVisited(limit: limit);
  }

  @override
  Future<List<WebsiteEntity>> getMostVisited({int limit = 10}) async {
    return _websiteDs.getMostVisited(limit: limit);
  }

  @override
  Future<int> getTotalCount() async {
    return _websiteDs.getTotalCount();
  }

  @override
  Future<bool> urlExists(String url) async {
    return _websiteDs.urlExists(url);
  }

  @override
  Future<void> insertBatch(List<WebsiteEntity> websites) async {
    final models = websites.map((w) => WebsiteModel.fromEntity(w)).toList();
    await _websiteDs.insertBatch(models);
  }
}
