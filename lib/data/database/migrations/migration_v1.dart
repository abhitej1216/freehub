import 'package:sqflite/sqflite.dart';
import '../../../core/constants/database_constants.dart';

class MigrationV1 {
  MigrationV1._();

  static Future<void> up(Database db) async {
    await db.execute(DatabaseConstants.createCategoriesTable);
    await db.execute(DatabaseConstants.createWebsitesTable);
    await db.execute(DatabaseConstants.createVisitHistoryTable);

    // Create indexes
    await db.execute(DatabaseConstants.createWebsiteNameIndex);
    await db.execute(DatabaseConstants.createWebsiteUrlIndex);
    await db.execute(DatabaseConstants.createWebsiteCategoryIndex);
    await db.execute(DatabaseConstants.createWebsiteBookmarkIndex);
    await db.execute(DatabaseConstants.createVisitHistoryIndex);

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  static Future<void> _insertDefaultCategories(Database db) async {
    final categories = [
      {
        'name': 'Artificial Intelligence',
        'description': 'AI tools, chatbots, image generators, and ML resources',
        'icon': 'ai',
        'parent_category_id': null,
      },
      {
        'name': 'Streaming',
        'description': 'Video streaming, live TV, and on-demand content',
        'icon': 'streaming',
        'parent_category_id': null,
      },
      {
        'name': 'Listening / Music',
        'description': 'Music streaming, podcasts, and audio content',
        'icon': 'music',
        'parent_category_id': null,
      },
      {
        'name': 'Gaming',
        'description': 'Free games, game resources, and gaming tools',
        'icon': 'gaming',
        'parent_category_id': null,
      },
      {
        'name': 'Reading',
        'description': 'Books, articles, comics, and reading resources',
        'icon': 'reading',
        'parent_category_id': null,
      },
      {
        'name': 'Downloading',
        'description': 'Direct download sites for software and media',
        'icon': 'downloading',
        'parent_category_id': null,
      },
      {
        'name': 'Torrenting',
        'description': 'Torrent clients, trackers, and related tools',
        'icon': 'torrenting',
        'parent_category_id': null,
      },
      {
        'name': 'Educational',
        'description': 'Free courses, tutorials, and learning platforms',
        'icon': 'educational',
        'parent_category_id': null,
      },
      {
        'name': 'Android / iOS',
        'description': 'Free apps, APK sources, and mobile tools',
        'icon': 'android',
        'parent_category_id': null,
      },
      {
        'name': 'Linux / macOS',
        'description': 'Free and open-source desktop software',
        'icon': 'linux',
        'parent_category_id': null,
      },
      {
        'name': 'Privacy & Security',
        'description': 'VPNs, privacy tools, and security resources',
        'icon': 'privacy',
        'parent_category_id': null,
      },
      {
        'name': 'Productivity',
        'description': 'Task managers, note-taking, and productivity tools',
        'icon': 'productivity',
        'parent_category_id': null,
      },
      {
        'name': 'Development Tools',
        'description': 'IDEs, APIs, hosting, and developer resources',
        'icon': 'development',
        'parent_category_id': null,
      },
      {
        'name': 'Design & Graphics',
        'description': 'Free design tools, assets, and creative resources',
        'icon': 'design',
        'parent_category_id': null,
      },
      {
        'name': 'Miscellaneous',
        'description': 'Other useful free internet resources',
        'icon': 'miscellaneous',
        'parent_category_id': null,
      },
    ];

    final batch = db.batch();
    for (final cat in categories) {
      batch.insert(
        DatabaseConstants.tableCategories,
        cat,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }
}
