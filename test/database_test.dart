import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:freehub/data/database/database_helper.dart';
import 'package:freehub/data/datasources/category_local_datasource.dart';
import 'package:freehub/data/datasources/visit_history_datasource.dart';
import 'package:freehub/data/datasources/website_local_datasource.dart';
import 'package:freehub/data/models/website_model.dart';
import 'package:freehub/data/repositories/category_repository_impl.dart';
import 'package:freehub/data/repositories/website_repository_impl.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('SQLite Database Integration Tests', () {
    late DatabaseHelper dbHelper;
    late WebsiteLocalDatasource websiteDs;
    late CategoryLocalDatasource categoryDs;
    late VisitHistoryDatasource historyDs;
    late WebsiteRepositoryImpl websiteRepo;
    late CategoryRepositoryImpl categoryRepo;

    setUp(() async {
      dbHelper = DatabaseHelper.instance;
      websiteDs = WebsiteLocalDatasource(dbHelper);
      categoryDs = CategoryLocalDatasource(dbHelper);
      historyDs = VisitHistoryDatasource(dbHelper);
      websiteRepo = WebsiteRepositoryImpl(websiteDs, historyDs);
      categoryRepo = CategoryRepositoryImpl(categoryDs);
    });

    test('Default 15 FMHY categories are seeded in SQLite', () async {
      final categories = await categoryRepo.getAllCategories();
      expect(categories.length, greaterThanOrEqualTo(15));
      expect(categories.any((c) => c.name == 'Artificial Intelligence'), isTrue);
      expect(categories.any((c) => c.name == 'Streaming'), isTrue);
      expect(categories.any((c) => c.name == 'Development Tools'), isTrue);
    });

    test('Add website, search it, bookmark it, and record visit', () async {
      const site = WebsiteModel(
        name: 'Internet Archive',
        url: 'https://archive.org',
        description: 'Universal access to all knowledge',
        tags: ['archive', 'books', 'media'],
        websiteType: 'Free',
        source: 'CUSTOM',
        dateAdded: '2026-11-12T00:00:00Z',
        lastUpdated: '2026-11-12T00:00:00Z',
      );

      final created = await websiteRepo.addWebsite(site);
      expect(created.id, isNotNull);

      // Search
      final searchResults = await websiteRepo.search('archive');
      expect(searchResults.any((w) => w.name == 'Internet Archive'), isTrue);

      // Bookmark
      final bookmarked = await websiteRepo.toggleBookmark(created.id!);
      expect(bookmarked.isBookmarked, isTrue);

      final allBookmarks = await websiteRepo.getBookmarked();
      expect(allBookmarks.any((w) => w.id == created.id), isTrue);

      // Visit history
      await websiteRepo.recordVisit(created.id!);
      final recent = await websiteRepo.getRecentlyVisited();
      expect(recent.any((w) => w.id == created.id), isTrue);

      // Clean up
      await websiteRepo.deleteWebsite(created.id!);
      final afterDelete = await websiteRepo.getById(created.id!);
      expect(afterDelete, isNull);
    });
  });
}
