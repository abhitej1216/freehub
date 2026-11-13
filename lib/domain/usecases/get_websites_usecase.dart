import '../entities/website_entity.dart';
import '../repositories/website_repository.dart';

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

  Future<List<WebsiteEntity>> getRecentlyVisited({int limit = 10}) {
    return _repository.getRecentlyVisited(limit: limit);
  }

  Future<int> getTotalCount() {
    return _repository.getTotalCount();
  }
}
