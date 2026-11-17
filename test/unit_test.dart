import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:freehub/core/utils/date_utils.dart';
import 'package:freehub/core/utils/url_utils.dart';
import 'package:freehub/data/models/category_model.dart';
import 'package:freehub/data/models/website_model.dart';
import 'package:freehub/domain/entities/website_entity.dart';
import 'package:freehub/domain/repositories/website_repository.dart';
import 'package:freehub/domain/usecases/get_websites_usecase.dart';

void main() {
  group('UrlUtils Tests', () {
    test('validates proper URLs correctly', () {
      expect(UrlUtils.isValid('https://fmhy.net'), isTrue);
      expect(UrlUtils.isValid('http://example.com/test'), isTrue);
      expect(UrlUtils.isValid('not-a-url'), isFalse);
      expect(UrlUtils.isValid(''), isFalse);
    });

    test('normalizes URLs missing scheme', () {
      expect(UrlUtils.normalize('fmhy.net'), equals('https://fmhy.net'));
      expect(UrlUtils.normalize('https://fmhy.net'), equals('https://fmhy.net'));
    });

    test('extracts domain correctly', () {
      expect(UrlUtils.getDomain('https://www.google.com/search'), equals('google.com'));
      expect(UrlUtils.getDomain('https://photopea.com'), equals('photopea.com'));
    });

    test('suggests website name from domain', () {
      expect(UrlUtils.getSuggestedName('https://photopea.com'), equals('Photopea'));
      expect(UrlUtils.getSuggestedName('https://www.github.com/flutter'), equals('Github'));
    });
  });

  group('DateUtils Tests', () {
    test('formats ISO dates correctly', () {
      final now = AppDateUtils.now();
      expect(now, isNotEmpty);
      expect(AppDateUtils.timeAgo(now), equals('Just now'));
    });
  });

  group('Model Serialization Tests', () {
    test('CategoryModel toMap and fromMap match', () {
      const model = CategoryModel(
        id: 1,
        name: 'Artificial Intelligence',
        description: 'AI Tools',
        icon: 'ai',
        websiteCount: 15,
      );

      final map = model.toMap();
      expect(map['name'], equals('Artificial Intelligence'));
      expect(map['icon'], equals('ai'));

      final fromMap = CategoryModel.fromMap({...map, 'website_count': 15});
      expect(fromMap.name, equals(model.name));
      expect(fromMap.websiteCount, equals(15));
    });

    test('WebsiteModel tags serialization works', () {
      const model = WebsiteModel(
        id: 10,
        name: 'Photopea',
        url: 'https://photopea.com',
        description: 'Online Photoshop alternative',
        tags: ['photo', 'editor', 'design'],
        websiteType: 'Free',
        source: 'CUSTOM',
        isBookmarked: true,
        dateAdded: '2026-11-12T00:00:00Z',
        lastUpdated: '2026-11-12T00:00:00Z',
      );

      final map = model.toMap();
      expect(map['is_bookmarked'], equals(1));
      expect(map['tags'], equals('["photo","editor","design"]'));

      final fromMap = WebsiteModel.fromMap(map);
      expect(fromMap.name, equals('Photopea'));
      expect(fromMap.isBookmarked, isTrue);
      expect(fromMap.tags, contains('photo'));
      expect(fromMap.tags.length, equals(3));
    });
  });

  group('GetWebsitesUseCase sorting', () {
    late GetWebsitesUseCase useCase;

    setUp(() {
      useCase = GetWebsitesUseCase(_FakeWebsiteRepository());
    });

    test('sortBookmarks filters by query and orders alphabetically', () {
      final sites = [
        _makeSite('Zeta', 'https://zeta.org', '2026-11-12T00:00:00Z'),
        _makeSite('Alpha', 'https://alpha.org', '2026-11-12T00:00:00Z'),
        _makeSite('Bravo', 'https://bravo.org', '2026-11-12T00:00:00Z'),
      ];

      final sorted = useCase.sortBookmarks(sites, '', WebsiteSort.alphabetical);
      expect(sorted.map((s) => s.name), equals(['Alpha', 'Bravo', 'Zeta']));

      final filtered = useCase.sortBookmarks(sites, 'bravo');
      expect(filtered.map((s) => s.name), equals(['Bravo']));
    });

    test('recentlyAdded sorts newest first', () {
      final sites = [
        _makeSite('Old', 'https://old.org', '2026-11-01T00:00:00Z'),
        _makeSite('New', 'https://new.org', '2026-11-12T00:00:00Z'),
        _makeSite('Middle', 'https://middle.org', '2026-11-06T00:00:00Z'),
      ];

      final sorted = useCase.sortBookmarks(
        sites,
        '',
        WebsiteSort.recentlyAdded,
      );
      expect(sorted.map((s) => s.name), equals(['New', 'Middle', 'Old']));
    });

    test('mostVisited falls back to alphabetical on ties', () {
      // Same lastUpdated -> tie, so alphabetical order should win.
      final sites = [
        _makeSite('Zeta', 'https://zeta.org', '2026-11-12T00:00:00Z'),
        _makeSite('Alpha', 'https://alpha.org', '2026-11-12T00:00:00Z'),
      ];

      final sorted = useCase.sortBookmarks(
        sites,
        '',
        WebsiteSort.mostVisited,
      );
      expect(sorted.map((s) => s.name), equals(['Alpha', 'Zeta']));
    });
  });
}

class _FakeWebsiteRepository implements WebsiteRepository {
  @override
  Future<List<WebsiteEntity>> getAllWebsites({int? limit, int? offset}) async =>
      const [];

  @override
  Future<List<WebsiteEntity>> getRecentlyAdded({int limit = 10}) async =>
      const [];

  @override
  Future<List<WebsiteEntity>> getBookmarked() async => const [];

  @override
  Future<List<WebsiteEntity>> getByCategory(int categoryId) async =>
      const [];

  @override
  Future<WebsiteEntity?> getById(int id) async => null;

  @override
  Future<WebsiteEntity?> getByUrl(String url) async => null;

  @override
  Future<WebsiteEntity?> getByUrlCaseInsensitive(String url) async => null;

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
  }) async =>
      const [];

  @override
  Future<WebsiteEntity> addWebsite(WebsiteEntity website) async => website;

  @override
  Future<WebsiteEntity> updateWebsite(WebsiteEntity website) async => website;

  @override
  Future<void> deleteWebsite(int id) async {}

  @override
  Future<WebsiteEntity> toggleBookmark(int id) async =>
      throw UnimplementedError();

  @override
  Future<void> recordVisit(int websiteId) async {}

  @override
  Future<List<WebsiteEntity>> getRecentlyVisited({int limit = 10}) async =>
      const [];

  @override
  Future<List<WebsiteEntity>> getMostVisited({int limit = 10}) async =>
      const [];

  @override
  Future<int> getTotalCount() async => 0;

  @override
  Future<bool> urlExists(String url) async => false;

  @override
  Future<void> insertBatch(List<WebsiteEntity> websites) async {}

  @override
  Future<int> addWebsiteTx(Transaction txn, WebsiteEntity website) async => 0;

  @override
  Future<int> updateWebsiteTx(Transaction txn, WebsiteEntity website) async => 0;

  @override
  Future<WebsiteEntity?> getByUrlCaseInsensitiveTx(
      Transaction txn, String url) async =>
      null;
}

WebsiteEntity _makeSite(String name, String url, String date) =>
    WebsiteEntity(
      name: name,
      url: url,
      dateAdded: date,
      lastUpdated: date,
    );
