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
  });
}
