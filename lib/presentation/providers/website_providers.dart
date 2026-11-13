import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/website_entity.dart';
import 'database_providers.dart';
import 'category_providers.dart';

class DashboardStats {
  final int totalWebsites;
  final int totalCategories;
  final int totalBookmarks;
  final int totalVisits;

  const DashboardStats({
    this.totalWebsites = 0,
    this.totalCategories = 0,
    this.totalBookmarks = 0,
    this.totalVisits = 0,
  });
}

// Signal to trigger updates across website-related providers
final websiteUpdateTriggerProvider = StateProvider<int>((ref) => 0);

// Dashboard metrics provider
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  ref.watch(websiteUpdateTriggerProvider);
  final dbHelper = ref.watch(databaseHelperProvider);
  final info = await dbHelper.getDatabaseInfo();

  return DashboardStats(
    totalWebsites: info['website_count'] as int? ?? 0,
    totalCategories: info['category_count'] as int? ?? 0,
    totalBookmarks: info['bookmark_count'] as int? ?? 0,
    totalVisits: info['history_count'] as int? ?? 0,
  );
});

// Recently added websites provider
final recentlyAddedWebsitesProvider =
    FutureProvider<List<WebsiteEntity>>((ref) async {
  ref.watch(websiteUpdateTriggerProvider);
  final useCase = ref.watch(getWebsitesUseCaseProvider);
  return useCase.getRecentlyAdded(limit: 10);
});

// Recently visited websites provider
final recentlyVisitedWebsitesProvider =
    FutureProvider<List<WebsiteEntity>>((ref) async {
  ref.watch(websiteUpdateTriggerProvider);
  final useCase = ref.watch(getWebsitesUseCaseProvider);
  return useCase.getRecentlyVisited(limit: 10);
});

// Bookmarked websites provider
final bookmarkedWebsitesProvider =
    FutureProvider<List<WebsiteEntity>>((ref) async {
  ref.watch(websiteUpdateTriggerProvider);
  final useCase = ref.watch(getWebsitesUseCaseProvider);
  return useCase.getBookmarked();
});

// Websites by category provider
final websitesByCategoryProvider =
    FutureProvider.family<List<WebsiteEntity>, int>((ref, categoryId) async {
  ref.watch(websiteUpdateTriggerProvider);
  final useCase = ref.watch(getWebsitesUseCaseProvider);
  return useCase.getByCategory(categoryId);
});

// Websites controller for mutations
class WebsiteController {
  final Ref _ref;

  WebsiteController(this._ref);

  Future<WebsiteEntity> toggleBookmark(int websiteId) async {
    final repo = _ref.read(websiteRepositoryProvider);
    final updated = await repo.toggleBookmark(websiteId);
    _ref.read(websiteUpdateTriggerProvider.notifier).state++;
    return updated;
  }

  Future<void> recordVisit(int websiteId) async {
    final repo = _ref.read(websiteRepositoryProvider);
    await repo.recordVisit(websiteId);
    _ref.read(websiteUpdateTriggerProvider.notifier).state++;
  }

  Future<WebsiteEntity> addWebsite(WebsiteEntity website) async {
    final repo = _ref.read(websiteRepositoryProvider);
    final created = await repo.addWebsite(website);
    _ref.read(websiteUpdateTriggerProvider.notifier).state++;
    _ref.read(categoriesProvider.notifier).loadCategories();
    return created;
  }

  Future<WebsiteEntity> updateWebsite(WebsiteEntity website) async {
    final repo = _ref.read(websiteRepositoryProvider);
    final updated = await repo.updateWebsite(website);
    _ref.read(websiteUpdateTriggerProvider.notifier).state++;
    _ref.read(categoriesProvider.notifier).loadCategories();
    return updated;
  }

  Future<void> deleteWebsite(int id) async {
    final repo = _ref.read(websiteRepositoryProvider);
    await repo.deleteWebsite(id);
    _ref.read(websiteUpdateTriggerProvider.notifier).state++;
    _ref.read(categoriesProvider.notifier).loadCategories();
  }

  void refreshAll() {
    _ref.read(websiteUpdateTriggerProvider.notifier).state++;
    _ref.read(categoriesProvider.notifier).loadCategories();
  }
}

final websiteControllerProvider = Provider<WebsiteController>((ref) {
  return WebsiteController(ref);
});
