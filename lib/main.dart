import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'data/database/database_helper.dart';
import 'data/datasources/category_local_datasource.dart';
import 'data/datasources/visit_history_datasource.dart';
import 'data/datasources/website_local_datasource.dart';
import 'data/repositories/category_repository_impl.dart';
import 'data/repositories/website_repository_impl.dart';
import 'presentation/providers/database_providers.dart';
import 'services/import_export_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize SQLite Database with safe error handling
  try {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.database;

    // Load initial bundled FMHY dataset if first launch
    final categoryDs = CategoryLocalDatasource(dbHelper);
    final websiteDs = WebsiteLocalDatasource(dbHelper);
    final historyDs = VisitHistoryDatasource(dbHelper);
    final categoryRepo = CategoryRepositoryImpl(categoryDs);
    final websiteRepo = WebsiteRepositoryImpl(websiteDs, historyDs);

    final importExportService = ImportExportService(
      dbHelper,
      websiteRepo,
      categoryRepo,
      sharedPreferences,
    );
    await importExportService.importInitialDataIfNeeded();
  } catch (e, st) {
    debugPrint('Startup initialization notice: $e\n$st');
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const FreeHubApp(),
    ),
  );
}
