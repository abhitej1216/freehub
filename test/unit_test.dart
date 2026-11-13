import 'package:flutter_test/flutter_test.dart';
import 'package:freehub/core/utils/date_utils.dart';
import 'package:freehub/core/utils/url_utils.dart';
import 'package:freehub/data/models/category_model.dart';
import 'package:freehub/data/models/website_model.dart';

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
}
