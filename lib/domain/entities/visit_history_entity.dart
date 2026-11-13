class VisitHistoryEntity {
  final int? id;
  final int websiteId;
  final String visitedAt;
  final WebsiteInfo? website;

  const VisitHistoryEntity({
    this.id,
    required this.websiteId,
    required this.visitedAt,
    this.website,
  });
}

class WebsiteInfo {
  final int id;
  final String name;
  final String url;
  final String? faviconUrl;
  final String? categoryName;

  const WebsiteInfo({
    required this.id,
    required this.name,
    required this.url,
    this.faviconUrl,
    this.categoryName,
  });
}
