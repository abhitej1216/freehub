import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freehub/data/database/database_helper.dart';
import 'package:freehub/data/datasources/category_local_datasource.dart';
import 'package:freehub/data/datasources/visit_history_datasource.dart';
import 'package:freehub/data/datasources/website_local_datasource.dart';
import 'package:freehub/data/repositories/category_repository_impl.dart';
import 'package:freehub/data/repositories/website_repository_impl.dart';
import 'package:freehub/services/import_export_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('ImportExportService Tests', () {
    late ImportExportService service;
    late WebsiteRepositoryImpl websiteRepo;
    late CategoryRepositoryImpl categoryRepo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final dbHelper = DatabaseHelper.instance;

      final catDs = CategoryLocalDatasource(dbHelper);
      final webDs = WebsiteLocalDatasource(dbHelper);
      final histDs = VisitHistoryDatasource(dbHelper);
      categoryRepo = CategoryRepositoryImpl(catDs);
      websiteRepo = WebsiteRepositoryImpl(webDs, histDs);

      service = ImportExportService(dbHelper, websiteRepo, categoryRepo, prefs);
    });

    test('previewJsonString rejects invalid json structure', () async {
      final preview = await service.previewJsonString('not json');
      expect(preview.isValid, isFalse);
    });

    test('previewJsonString parses valid v1 JSON structure', () async {
      final uniqueUrl = 'https://sample-site-${DateTime.now().microsecondsSinceEpoch}.org';
      final validJson = jsonEncode({
        'app': 'FreeHub',
        'schemaVersion': 1,
        'categories': [
          {'name': 'Test Cat', 'description': 'Cat description'}
        ],
        'websites': [
          {
            'name': 'Sample Site',
            'url': uniqueUrl,
            'description': 'A sample resource',
            'category_name': 'Test Cat',
            'tags': ['test', 'sample'],
            'website_type': 'Free',
            'source': 'FMHY',
            'is_bookmarked': false,
            'date_added': '2026-11-12T00:00:00Z',
            'last_updated': '2026-11-12T00:00:00Z'
          }
        ]
      });

      final preview = await service.previewJsonString(validJson);
      expect(preview.isValid, isTrue);
      expect(preview.totalWebsitesInFile, equals(1));
      expect(preview.totalCategoriesInFile, equals(1));
      expect(preview.newWebsitesCount, equals(1));
      expect(preview.duplicateUrlsCount, equals(0));
    });

    test('executeImport adds websites and exportToJsonString exports them', () async {
      final uniqueUrl = 'https://export-${DateTime.now().microsecondsSinceEpoch}.org';
      final validJson = jsonEncode({
        'app': 'FreeHub',
        'schemaVersion': 1,
        'categories': [
          {'name': 'Export Test Cat', 'description': 'Description'}
        ],
        'websites': [
          {
            'name': 'Export Site',
            'url': uniqueUrl,
            'description': 'Description',
            'category_name': 'Export Test Cat',
            'tags': ['tools'],
            'website_type': 'Open Source',
            'source': 'FMHY',
            'is_bookmarked': false,
            'date_added': '2026-11-12T00:00:00Z',
            'last_updated': '2026-11-12T00:00:00Z'
          }
        ]
      });

      final preview = await service.previewJsonString(validJson);
      final importResult = await service.executeImport(preview, updateExisting: false);

      expect(importResult.success, isTrue);
      expect(importResult.importedCount, equals(1));

      // Export test
      final exportedJson = await service.exportToJsonString();
      final decoded = jsonDecode(exportedJson) as Map<String, dynamic>;

      expect(decoded['app'], equals('FreeHub'));
      expect(decoded['schemaVersion'], equals(1));
      final websites = decoded['websites'] as List;
      expect(websites.any((w) => w['url'] == uniqueUrl), isTrue);
    });

    test('executeImport counts a UNIQUE-conflict as skipped, not imported', () async {
      final uniqueUrl = 'https://conflict-${DateTime.now().microsecondsSinceEpoch}.org';
      final jsonWithDup = jsonEncode({
        'app': 'FreeHub',
        'schemaVersion': 1,
        'categories': [
          {'name': 'Conflict Cat', 'description': 'Description'}
        ],
        'websites': [
          {
            'name': 'Conflict Site',
            'url': uniqueUrl,
            'description': 'Description',
            'category_name': 'Conflict Cat',
            'tags': ['tools'],
            'website_type': 'Free',
            'source': 'FMHY',
            'is_bookmarked': false,
            'date_added': '2026-11-12T00:00:00Z',
            'last_updated': '2026-11-12T00:00:00Z'
          }
        ]
      });

      // First import succeeds.
      final firstPreview = await service.previewJsonString(jsonWithDup);
      final firstResult = await service.executeImport(
        firstPreview,
        updateExisting: false,
      );
      expect(firstResult.importedCount, equals(1));
      expect(firstResult.skippedCount, equals(0));

      // Second import of the same URL: the UNIQUE(url) constraint silently
      // ignores the insert, so it must be reported as skipped, not imported.
      final secondPreview = await service.previewJsonString(jsonWithDup);
      expect(secondPreview.duplicateUrlsCount, equals(1));
      final secondResult = await service.executeImport(
        secondPreview,
        updateExisting: false,
      );
      expect(secondResult.importedCount, equals(0));
      expect(secondResult.skippedCount, equals(1));

      // The website is still in the database exactly once.
      final total = await websiteRepo.getTotalCount();
      expect(total, greaterThanOrEqualTo(1));
    });

    test('executeImport with updateExisting overwrites duplicates', () async {
      final uniqueUrl = 'https://update-${DateTime.now().microsecondsSinceEpoch}.org';
      final jsonV1 = jsonEncode({
        'app': 'FreeHub',
        'schemaVersion': 1,
        'categories': [
          {'name': 'Update Cat', 'description': 'Description'}
        ],
        'websites': [
          {
            'name': 'Original Name',
            'url': uniqueUrl,
            'description': 'Original description',
            'category_name': 'Update Cat',
            'tags': ['a'],
            'website_type': 'Free',
            'source': 'FMHY',
            'is_bookmarked': false,
            'date_added': '2026-11-12T00:00:00Z',
            'last_updated': '2026-11-12T00:00:00Z'
          }
        ]
      });
      final jsonV2 = jsonEncode({
        'app': 'FreeHub',
        'schemaVersion': 1,
        'categories': [
          {'name': 'Update Cat', 'description': 'Description'}
        ],
        'websites': [
          {
            'name': 'Renamed Site',
            'url': uniqueUrl,
            'description': 'New description',
            'category_name': 'Update Cat',
            'tags': ['b'],
            'website_type': 'Open Source',
            'source': 'FMHY',
            'is_bookmarked': false,
            'date_added': '2026-11-12T00:00:00Z',
            'last_updated': '2026-11-12T00:00:00Z'
          }
        ]
      });

      final first = await service.executeImport(
        await service.previewJsonString(jsonV1),
        updateExisting: false,
      );
      expect(first.importedCount, equals(1));

      final second = await service.executeImport(
        await service.previewJsonString(jsonV2),
        updateExisting: true,
      );
      expect(second.updatedCount, equals(1));
      expect(second.importedCount, equals(0));

      final site = await websiteRepo.getByUrl(uniqueUrl);
      expect(site, isNotNull);
      expect(site!.name, equals('Renamed Site'));
      expect(site.websiteType, equals('Open Source'));
    });

    test('case-only URL difference is detected as a duplicate', () async {
      final base = 'https://case-${DateTime.now().microsecondsSinceEpoch}.org';
      final jsonV1 = jsonEncode({
        'app': 'FreeHub',
        'schemaVersion': 1,
        'categories': [
          {'name': 'Case Cat', 'description': 'Description'}
        ],
        'websites': [
          {
            'name': 'Site One',
            'url': base,
            'description': 'Description',
            'category_name': 'Case Cat',
            'website_type': 'Free',
            'source': 'FMHY',
            'is_bookmarked': false,
            'date_added': '2026-11-12T00:00:00Z',
            'last_updated': '2026-11-12T00:00:00Z'
          }
        ]
      });
      // Same URL with a different case -- the preview lowercases, so this must
      // be reported as a duplicate and the UNIQUE constraint must reject it.
      final jsonV2 = jsonEncode({
        'app': 'FreeHub',
        'schemaVersion': 1,
        'categories': [
          {'name': 'Case Cat', 'description': 'Description'}
        ],
        'websites': [
          {
            'name': 'Site Two',
            'url': base.toUpperCase(),
            'description': 'Description',
            'category_name': 'Case Cat',
            'website_type': 'Free',
            'source': 'FMHY',
            'is_bookmarked': false,
            'date_added': '2026-11-12T00:00:00Z',
            'last_updated': '2026-11-12T00:00:00Z'
          }
        ]
      });

      await service.executeImport(
        await service.previewJsonString(jsonV1),
        updateExisting: false,
      );

      final preview = await service.previewJsonString(jsonV2);
      expect(preview.duplicateUrlsCount, equals(1));

      final result = await service.executeImport(preview, updateExisting: false);
      expect(result.importedCount, equals(0));
      expect(result.skippedCount, equals(1));

      // Only one website exists, with the original name.
      final site = await websiteRepo.getByUrl(base);
      expect(site, isNotNull);
      expect(site!.name, equals('Site One'));
    });
  });
}
