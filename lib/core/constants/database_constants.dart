class DatabaseConstants {
  DatabaseConstants._();

  // Table names
  static const String tableWebsites = 'websites';
  static const String tableCategories = 'categories';
  static const String tableVisitHistory = 'visit_history';

  // Websites columns
  static const String colId = 'id';
  static const String colName = 'name';
  static const String colUrl = 'url';
  static const String colDescription = 'description';
  static const String colCategoryId = 'category_id';
  static const String colSubcategory = 'subcategory';
  static const String colFaviconUrl = 'favicon_url';
  static const String colTags = 'tags';
  static const String colWebsiteType = 'website_type';
  static const String colSource = 'source';
  static const String colIsBookmarked = 'is_bookmarked';
  static const String colDateAdded = 'date_added';
  static const String colLastUpdated = 'last_updated';

  // Categories columns
  static const String colCatId = 'id';
  static const String colCatName = 'name';
  static const String colCatDescription = 'description';
  static const String colCatIcon = 'icon';
  static const String colParentCategoryId = 'parent_category_id';

  // Visit history columns
  static const String colVisitId = 'id';
  static const String colWebsiteId = 'website_id';
  static const String colVisitedAt = 'visited_at';

  // Create table statements
  static const String createWebsitesTable = '''
    CREATE TABLE IF NOT EXISTS $tableWebsites (
      $colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colName TEXT NOT NULL,
      $colUrl TEXT UNIQUE NOT NULL,
      $colDescription TEXT,
      $colCategoryId INTEGER,
      $colSubcategory TEXT,
      $colFaviconUrl TEXT,
      $colTags TEXT DEFAULT '[]',
      $colWebsiteType TEXT DEFAULT 'Free',
      $colSource TEXT DEFAULT 'CUSTOM',
      $colIsBookmarked INTEGER DEFAULT 0,
      $colDateAdded TEXT NOT NULL,
      $colLastUpdated TEXT NOT NULL,
      FOREIGN KEY ($colCategoryId) REFERENCES $tableCategories($colCatId) ON DELETE SET NULL
    )
  ''';

  static const String createCategoriesTable = '''
    CREATE TABLE IF NOT EXISTS $tableCategories (
      $colCatId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colCatName TEXT UNIQUE NOT NULL,
      $colCatDescription TEXT,
      $colCatIcon TEXT,
      $colParentCategoryId INTEGER,
      FOREIGN KEY ($colParentCategoryId) REFERENCES $tableCategories($colCatId) ON DELETE SET NULL
    )
  ''';

  static const String createVisitHistoryTable = '''
    CREATE TABLE IF NOT EXISTS $tableVisitHistory (
      $colVisitId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colWebsiteId INTEGER NOT NULL,
      $colVisitedAt TEXT NOT NULL,
      FOREIGN KEY ($colWebsiteId) REFERENCES $tableWebsites($colId) ON DELETE CASCADE
    )
  ''';

  // Indexes
  static const String createWebsiteNameIndex =
      'CREATE INDEX IF NOT EXISTS idx_websites_name ON $tableWebsites($colName)';
  static const String createWebsiteUrlIndex =
      'CREATE INDEX IF NOT EXISTS idx_websites_url ON $tableWebsites($colUrl)';
  static const String createWebsiteCategoryIndex =
      'CREATE INDEX IF NOT EXISTS idx_websites_category ON $tableWebsites($colCategoryId)';
  static const String createWebsiteBookmarkIndex =
      'CREATE INDEX IF NOT EXISTS idx_websites_bookmark ON $tableWebsites($colIsBookmarked)';
  static const String createVisitHistoryIndex =
      'CREATE INDEX IF NOT EXISTS idx_visit_history_website ON $tableVisitHistory($colWebsiteId)';
}
