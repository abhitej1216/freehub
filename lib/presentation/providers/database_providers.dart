import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/database/database_helper.dart';
import '../../data/datasources/category_local_datasource.dart';
import '../../data/datasources/visit_history_datasource.dart';
import '../../data/datasources/website_local_datasource.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/repositories/website_repository_impl.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/website_repository.dart';
import '../../domain/usecases/get_websites_usecase.dart';
import '../../services/import_export_service.dart';

// SharedPreferences provider (must be overridden in main with instance)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized before use');
});

// Database Helper provider
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

// Datasource providers
final categoryLocalDatasourceProvider =
    Provider<CategoryLocalDatasource>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return CategoryLocalDatasource(dbHelper);
});

final websiteLocalDatasourceProvider = Provider<WebsiteLocalDatasource>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return WebsiteLocalDatasource(dbHelper);
});

final visitHistoryDatasourceProvider = Provider<VisitHistoryDatasource>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return VisitHistoryDatasource(dbHelper);
});

// Repository providers
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final datasource = ref.watch(categoryLocalDatasourceProvider);
  return CategoryRepositoryImpl(datasource);
});

final websiteRepositoryProvider = Provider<WebsiteRepository>((ref) {
  final websiteDs = ref.watch(websiteLocalDatasourceProvider);
  final historyDs = ref.watch(visitHistoryDatasourceProvider);
  return WebsiteRepositoryImpl(websiteDs, historyDs);
});

// UseCase providers
final getWebsitesUseCaseProvider = Provider<GetWebsitesUseCase>((ref) {
  final repository = ref.watch(websiteRepositoryProvider);
  return GetWebsitesUseCase(repository);
});

// Import / Export Service provider
final importExportServiceProvider = Provider<ImportExportService>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  final websiteRepo = ref.watch(websiteRepositoryProvider);
  final categoryRepo = ref.watch(categoryRepositoryProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return ImportExportService(dbHelper, websiteRepo, categoryRepo, prefs);
});
