import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:freehub/data/database/database_helper.dart';
import 'package:freehub/data/datasources/category_local_datasource.dart';
import 'package:freehub/data/datasources/visit_history_datasource.dart';
import 'package:freehub/data/datasources/website_local_datasource.dart';
import 'package:freehub/data/repositories/category_repository_impl.dart';
import 'package:freehub/data/repositories/website_repository_impl.dart';
import 'package:freehub/services/fmhy_sync_service.dart';
import 'package:freehub/services/import_export_service.dart';

class FakeHttpClient extends http.BaseClient {
  final Future<http.Response> Function(http.BaseRequest request) handler;

  FakeHttpClient(this.handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await handler(request);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
    );
  }
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('FmhySyncService Markdown Parsing Tests', () {
    test('parseMarkdownToWebsites extracts titles, links, descriptions, and tags', () {
      const markdown = '''
# Artificial Intelligence
## Chatbots
* ⭐ [Claude AI](https://claude.ai) - Conversational assistant by Anthropic (Freemium)
* [ChatGPT](https://chatgpt.com) - OpenAI conversational model
## Image Generators
* [Midjourney](https://midjourney.com) - Text to image AI generator (Paid)
''';

      final websites = FmhySyncService.parseMarkdownToWebsites(
        markdown,
        'Artificial Intelligence',
        maxPerCategory: 10,
      );

      expect(websites.length, equals(3));

      // Check first website (starred Claude AI)
      final claude = websites.firstWhere((w) => w.name == 'Claude AI');
      expect(claude.url, equals('https://claude.ai'));
      expect(claude.categoryName, equals('Artificial Intelligence'));
      expect(claude.subcategory, equals('Chatbots'));
      expect(claude.websiteType, equals('Freemium'));
      expect(claude.tags, contains('popular'));
      expect(claude.source, equals('FMHY'));

      // Check second website
      final chatgpt = websites.firstWhere((w) => w.name == 'ChatGPT');
      expect(chatgpt.url, equals('https://chatgpt.com'));
      expect(chatgpt.subcategory, equals('Chatbots'));
      expect(chatgpt.websiteType, equals('Free'));

      // Check third website
      final midjourney = websites.firstWhere((w) => w.name == 'Midjourney');
      expect(midjourney.subcategory, equals('Image Generators'));
      expect(midjourney.websiteType, equals('Paid'));
    });

    test('parseMarkdownToWebsites enforces maxPerCategory limit', () {
      final buffer = StringBuffer('# Audio Resources\n## Music\n');
      for (int i = 0; i < 50; i++) {
        buffer.writeln('* [Site $i](https://site$i.org) - Description for site $i');
      }

      final websites = FmhySyncService.parseMarkdownToWebsites(
        buffer.toString(),
        'Audio',
        maxPerCategory: 15,
      );

      expect(websites.length, equals(15));
    });
  });

  group('FmhySyncService GitHub Sync Integration Tests', () {
    late ImportExportService importExportService;
    late CategoryRepositoryImpl categoryRepo;
    late WebsiteRepositoryImpl websiteRepo;
    late DatabaseHelper dbHelper;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      dbHelper = DatabaseHelper.instance;

      final catDs = CategoryLocalDatasource(dbHelper);
      final webDs = WebsiteLocalDatasource(dbHelper);
      final histDs = VisitHistoryDatasource(dbHelper);
      categoryRepo = CategoryRepositoryImpl(catDs);
      websiteRepo = WebsiteRepositoryImpl(webDs, histDs);

      importExportService = ImportExportService(dbHelper, websiteRepo, categoryRepo, prefs);
    });

    test('syncFromGithub successfully imports resources from mock client', () async {
      final uniqueDomain = 'test-sync-${DateTime.now().microsecondsSinceEpoch}';
      final client = FakeHttpClient((request) async {
        final slug = request.url.pathSegments.last;
        return http.Response(
          '''
# Category Doc
## Subcategory
* ⭐ [Mock Site $slug 1](https://$uniqueDomain-$slug-1.com) - First mock website (Free)
* [Mock Site $slug 2](https://$uniqueDomain-$slug-2.com) - Second mock website (Open Source)
''',
          200,
          headers: {'content-type': 'text/plain; charset=utf-8'},
        );
      });

      final syncService = FmhySyncService(importExportService, client);
      final progressUpdates = <String>[];

      final result = await syncService.syncFromGithub(
        onProgress: (status, progress) {
          progressUpdates.add(status);
        },
        maxPerCategory: 2,
        updateExisting: false,
      );

      expect(result.success, isTrue);
      expect(result.totalFetched, greaterThan(0));
      expect(result.newAdded, greaterThan(0));
      expect(progressUpdates, isNotEmpty);

      // Verify a website exists in the repository
      final fetched1 = await websiteRepo.getByUrl('https://$uniqueDomain-ai.md-1.com');
      expect(fetched1, isNotNull);
      expect(fetched1!.name, equals('Mock Site ai.md 1'));
      expect(fetched1.websiteType, equals('Free'));

      final fetched2 = await websiteRepo.getByUrl('https://$uniqueDomain-ai.md-2.com');
      expect(fetched2, isNotNull);
      expect(fetched2!.name, equals('Mock Site ai.md 2'));
      expect(fetched2.websiteType, equals('Open Source'));

      // Re-sync with updateExisting: false should count duplicates as skipped
      final reSyncResult = await syncService.syncFromGithub(
        maxPerCategory: 2,
        updateExisting: false,
      );
      expect(reSyncResult.success, isTrue);
      expect(reSyncResult.skipped, greaterThan(0));
      expect(reSyncResult.newAdded, equals(0));
    });

    test('syncFromGithub handles connection failures gracefully', () async {
      final failingClient = FakeHttpClient((request) async {
        return http.Response('Server error', 500);
      });

      final syncService = FmhySyncService(importExportService, failingClient);
      final result = await syncService.syncFromGithub();

      expect(result.success, isFalse);
      expect(result.totalFetched, equals(0));
      expect(result.message, contains('Could not connect to GitHub'));
    });
  });
}
