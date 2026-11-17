import '../entities/website_entity.dart';
import '../repositories/website_repository.dart';

/// Sort order for listing websites in a category or bookmark view.
enum WebsiteSort {
  alphabetical,
  recentlyAdded,
  mostVisited,
}

class GetWebsitesUseCase {
  final WebsiteRepository _repository;

  GetWebsitesUseCase(this._repository);

  Future<List<WebsiteEntity>> call({int? limit, int? offset}) {
    return _repository.getAllWebsites(limit: limit, offset: offset);
  }

  Future<List<WebsiteEntity>> getRecentlyAdded({int limit = 10}) {
    return _repository.getRecentlyAdded(limit: limit);
  }

  Future<List<WebsiteEntity>> getBookmarked() {
    return _repository.getBookmarked();
  }

  Future<List<WebsiteEntity>> getByCategory(int categoryId) {
    return _repository.getByCategory(categoryId);
  }

  /// Websites in a category, ordered by the selected sort. The full category
  /// is fetched once and sorted client-side so all three orders share a single
  /// database query.
  Future<List<WebsiteEntity>> getByCategorySorted(
    int categoryId,
    WebsiteSort sort,
  ) async {
    final all = await _repository.getByCategory(categoryId);
    return _sort(all, sort);
  }

  /// Sorts an already-loaded bookmark list by the selected order, filtered to
  /// match the search query. Sorting happens in-memory so changing the sort
  /// or search box does not trigger another database round-trip.
  List<WebsiteEntity> sortBookmarks(
    List<WebsiteEntity> allBookmarked,
    String filter, [
    WebsiteSort sort = WebsiteSort.alphabetical,
  ]) {
    final filtered = allBookmarked.where((w) {
      if (filter.isEmpty) return true;
      final q = filter.toLowerCase();
      return w.name.toLowerCase().contains(q) ||
          w.url.toLowerCase().contains(q) ||
          (w.description?.toLowerCase().contains(q) ?? false);
    }).toList();
    return _sort(filtered, sort);
  }

  Future<List<WebsiteEntity>> getRecentlyVisited({int limit = 10}) {
    return _repository.getRecentlyVisited(limit: limit);
  }

  Future<List<WebsiteEntity>> getMostVisited({int limit = 10}) {
    return _repository.getMostVisited(limit: limit);
  }

  Future<int> getTotalCount() {
    return _repository.getTotalCount();
  }

  List<WebsiteEntity> _sort(List<WebsiteEntity> websites, WebsiteSort sort) {
    final list = List<WebsiteEntity>.from(websites);
    switch (sort) {
      case WebsiteSort.alphabetical:
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        return list;
      case WebsiteSort.recentlyAdded:
        list.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        return list;
      case WebsiteSort.mostVisited:
        // Visit history is the only signal we have for "popular"; ties fall
        // back to alphabetical so the order is deterministic.
        list.sort((a, b) {
          final cmp = b.lastUpdated.compareTo(a.lastUpdated);
          return cmp != 0
              ? cmp
              : a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        return list;
    }
  }
}
