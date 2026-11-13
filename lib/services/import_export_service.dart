import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/database_constants.dart';
import '../core/utils/date_utils.dart';
import '../core/utils/json_utils.dart';
import '../data/database/database_helper.dart';
import '../data/models/category_model.dart';
import '../data/models/website_model.dart';
import '../domain/repositories/category_repository.dart';
import '../domain/repositories/website_repository.dart';

class ImportPreview {
  final int totalWebsitesInFile;
  final int totalCategoriesInFile;
  final int duplicateUrlsCount;
  final int newWebsitesCount;
  final List<WebsiteModel> websitesToImport;
  final List<CategoryModel> categoriesToImport;
  final bool isValid;
  final String? errorMessage;

  const ImportPreview({
    required this.totalWebsitesInFile,
    required this.totalCategoriesInFile,
    required this.duplicateUrlsCount,
    required this.newWebsitesCount,
    required this.websitesToImport,
    required this.categoriesToImport,
    this.isValid = true,
    this.errorMessage,
  });
}

class ImportResult {
  final int importedCount;
  final int updatedCount;
  final int skippedCount;
  final int newCategoriesCount;
  final bool success;
  final String? message;

  const ImportResult({
    required this.importedCount,
    required this.updatedCount,
    required this.skippedCount,
    required this.newCategoriesCount,
    this.success = true,
    this.message,
  });
}

class ImportExportService {
  final DatabaseHelper _dbHelper;
  final WebsiteRepository _websiteRepo;
  final CategoryRepository _categoryRepo;
  final SharedPreferences _prefs;

  ImportExportService(
    this._dbHelper,
    this._websiteRepo,
    this._categoryRepo,
    this._prefs,
  );

  /// 1. Bundled FMHY Initial Data Import (Runs automatically on first launch)
  Future<int> importInitialDataIfNeeded() async {
    final alreadyInitialized =
        _prefs.getBool(AppConstants.prefDbInitialized) ?? false;
    final currentCount = await _websiteRepo.getTotalCount();

    // If already initialized and has data, don't overwrite
    if (alreadyInitialized && currentCount > 0) {
      return 0;
    }

    try {
      final jsonString =
          await rootBundle.loadString(AppConstants.initialDataAsset);
      final preview = await previewJsonString(jsonString);

      if (preview.isValid) {
        final result = await executeImport(
          preview,
          updateExisting: false,
          keepCustomWebsites: true,
        );
        await _prefs.setBool(AppConstants.prefDbInitialized, true);
        return result.importedCount;
      }
    } catch (e) {
      debugPrint('Initial dataset import error: $e');
    }
    return 0;
  }

  /// 2. Preview any JSON string (from file picker or text)
  Future<ImportPreview> previewJsonString(String jsonContent) async {
    try {
      final decoded = jsonDecode(jsonContent);
      if (decoded is! Map<String, dynamic>) {
        return const ImportPreview(
          totalWebsitesInFile: 0,
          totalCategoriesInFile: 0,
          duplicateUrlsCount: 0,
          newWebsitesCount: 0,
          websitesToImport: [],
          categoriesToImport: [],
          isValid: false,
          errorMessage: 'Invalid format: Root must be a JSON object.',
        );
      }

      final schemaVersion = decoded['schemaVersion'] ?? decoded['version'];
      if (schemaVersion == null) {
        return const ImportPreview(
          totalWebsitesInFile: 0,
          totalCategoriesInFile: 0,
          duplicateUrlsCount: 0,
          newWebsitesCount: 0,
          websitesToImport: [],
          categoriesToImport: [],
          isValid: false,
          errorMessage: 'Unsupported schema: Missing schemaVersion.',
        );
      }

      final rawCategories = decoded['categories'] as List? ?? [];
      final rawWebsites = decoded['websites'] as List? ?? [];

      final categoriesToImport = rawCategories
          .whereType<Map<String, dynamic>>()
          .map((m) => CategoryModel.fromJson(m))
          .toList();

      final websitesToImport = rawWebsites
          .whereType<Map<String, dynamic>>()
          .map((m) => WebsiteModel.fromJson(m))
          .toList();

      // Check existing URLs in SQLite
      final db = await _dbHelper.database;
      final existingUrlRows = await db.rawQuery(
          'SELECT ${DatabaseConstants.colUrl} FROM ${DatabaseConstants.tableWebsites}');
      final existingUrls = existingUrlRows
          .map((r) => (r[DatabaseConstants.colUrl] as String).toLowerCase().trim())
          .toSet();

      int duplicateCount = 0;
      int newCount = 0;

      for (final site in websitesToImport) {
        if (existingUrls.contains(site.url.toLowerCase().trim())) {
          duplicateCount++;
        } else {
          newCount++;
        }
      }

      return ImportPreview(
        totalWebsitesInFile: websitesToImport.length,
        totalCategoriesInFile: categoriesToImport.length,
        duplicateUrlsCount: duplicateCount,
        newWebsitesCount: newCount,
        websitesToImport: websitesToImport,
        categoriesToImport: categoriesToImport,
        isValid: true,
      );
    } catch (e) {
      return ImportPreview(
        totalWebsitesInFile: 0,
        totalCategoriesInFile: 0,
        duplicateUrlsCount: 0,
        newWebsitesCount: 0,
        websitesToImport: [],
        categoriesToImport: [],
        isValid: false,
        errorMessage: 'JSON Parse Error: $e',
      );
    }
  }

  /// 3. Execute Import with duplicate handling
  Future<ImportResult> executeImport(
    ImportPreview preview, {
    required bool updateExisting,
    bool keepCustomWebsites = true,
  }) async {
    if (!preview.isValid) {
      return ImportResult(
        importedCount: 0,
        updatedCount: 0,
        skippedCount: 0,
        newCategoriesCount: 0,
        success: false,
        message: preview.errorMessage,
      );
    }

    int newCategories = 0;
    int imported = 0;
    int updated = 0;
    int skipped = 0;

    // 1. Process Categories
    final existingCategories = await _categoryRepo.getAllCategories();
    final categoryMap = <String, int>{};

    for (final c in existingCategories) {
      if (c.id != null) {
        categoryMap[c.name.toLowerCase().trim()] = c.id!;
      }
    }

    for (final cat in preview.categoriesToImport) {
      final key = cat.name.toLowerCase().trim();
      if (!categoryMap.containsKey(key)) {
        final created = await _categoryRepo.addCategory(cat);
        if (created.id != null) {
          categoryMap[key] = created.id!;
          newCategories++;
        }
      }
    }

    // 2. Process Websites
    for (final site in preview.websitesToImport) {
      final existingSite = await _websiteRepo.getByUrl(site.url);

      // Resolve category ID by name
      int? assignedCategoryId = site.categoryId;
      if (site.categoryName != null) {
        assignedCategoryId = categoryMap[site.categoryName!.toLowerCase().trim()];
      }

      if (existingSite == null) {
        // Insert new entry
        final toAdd = site.copyWith(
          categoryId: assignedCategoryId ?? site.categoryId,
          source: site.source.isNotEmpty ? site.source : AppConstants.sourceFmhy,
        );
        await _websiteRepo.addWebsite(toAdd);
        imported++;
      } else {
        if (updateExisting) {
          // If existing site is CUSTOM and keepCustomWebsites is true, keep source as CUSTOM
          final preserveSource = (keepCustomWebsites && existingSite.isCustom)
              ? AppConstants.sourceCustom
              : site.source;

          final toUpdate = site.copyWith(
            id: existingSite.id,
            categoryId: assignedCategoryId ?? existingSite.categoryId,
            source: preserveSource,
            isBookmarked: existingSite.isBookmarked || site.isBookmarked,
            lastUpdated: AppDateUtils.now(),
          );
          await _websiteRepo.updateWebsite(toUpdate);
          updated++;
        } else {
          skipped++;
        }
      }
    }

    return ImportResult(
      importedCount: imported,
      updatedCount: updated,
      skippedCount: skipped,
      newCategoriesCount: newCategories,
      success: true,
      message: 'Successfully imported $imported new, updated $updated, and skipped $skipped entries.',
    );
  }

  /// 4. Export all application data to formatted JSON
  Future<String> exportToJsonString() async {
    final categories = await _categoryRepo.getAllCategories();
    final websites = await _websiteRepo.getAllWebsites();

    final exportData = {
      'app': AppConstants.appName,
      'schemaVersion': 1,
      'exportedAt': AppDateUtils.now(),
      'categories': categories
          .map((c) => {
                'id': c.id,
                'name': c.name,
                'description': c.description,
                'icon': c.icon,
                'parent_category_id': c.parentCategoryId,
              })
          .toList(),
      'websites': websites
          .map((w) => {
                'name': w.name,
                'url': w.url,
                'description': w.description,
                'category_id': w.categoryId,
                'category_name': w.categoryName,
                'subcategory': w.subcategory,
                'favicon_url': w.faviconUrl,
                'tags': w.tags,
                'website_type': w.websiteType,
                'source': w.source,
                'is_bookmarked': w.isBookmarked,
                'date_added': w.dateAdded,
                'last_updated': w.lastUpdated,
              })
          .toList(),
    };

    return JsonUtils.prettyEncode(exportData);
  }

  /// 5. Share / Export Backup File
  Future<void> shareBackup() async {
    final jsonStr = await exportToJsonString();
    final now = DateTime.now().toIso8601String().replaceAll(':', '-');
    final fileName = 'freehub_backup_$now.json';

    final bytes = utf8.encode(jsonStr);
    final xfile = XFile.fromData(
      Uint8List.fromList(bytes),
      mimeType: 'application/json',
      name: fileName,
    );

    await Share.shareXFiles([xfile], subject: 'FreeHub Directory Backup ($fileName)');
  }
}
