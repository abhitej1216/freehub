import 'dart:convert';
import '../../domain/entities/website_entity.dart';
import '../../core/constants/database_constants.dart';
import '../../core/utils/json_utils.dart';

class WebsiteModel extends WebsiteEntity {
  const WebsiteModel({
    super.id,
    required super.name,
    required super.url,
    super.description,
    super.categoryId,
    super.categoryName,
    super.subcategory,
    super.faviconUrl,
    super.tags,
    super.websiteType,
    super.source,
    super.isBookmarked,
    required super.dateAdded,
    required super.lastUpdated,
  });

  factory WebsiteModel.fromMap(Map<String, dynamic> map) {
    return WebsiteModel(
      id: map[DatabaseConstants.colId] as int?,
      name: map[DatabaseConstants.colName] as String,
      url: map[DatabaseConstants.colUrl] as String,
      description: map[DatabaseConstants.colDescription] as String?,
      categoryId: map[DatabaseConstants.colCategoryId] as int?,
      categoryName: map['category_name'] as String?,
      subcategory: map[DatabaseConstants.colSubcategory] as String?,
      faviconUrl: map[DatabaseConstants.colFaviconUrl] as String?,
      tags: JsonUtils.decodeList(map[DatabaseConstants.colTags] as String?),
      websiteType: map[DatabaseConstants.colWebsiteType] as String? ?? 'Free',
      source: map[DatabaseConstants.colSource] as String? ?? 'CUSTOM',
      isBookmarked: (map[DatabaseConstants.colIsBookmarked] as int? ?? 0) == 1,
      dateAdded: map[DatabaseConstants.colDateAdded] as String,
      lastUpdated: map[DatabaseConstants.colLastUpdated] as String,
    );
  }

  factory WebsiteModel.fromJson(Map<String, dynamic> json) {
    List<String> tags = [];
    final rawTags = json['tags'];
    if (rawTags is List) {
      tags = rawTags.map((e) => e.toString()).toList();
    } else if (rawTags is String) {
      tags = JsonUtils.decodeList(rawTags);
    }

    final rawBm = json['is_bookmarked'];
    final bool isBm = rawBm == true || rawBm == 1 || rawBm == '1' || rawBm == 'true';

    final now = DateTime.now().toUtc().toIso8601String();
    return WebsiteModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      url: json['url'] as String,
      description: json['description'] as String?,
      categoryId: json['category_id'] as int?,
      categoryName: json['category_name'] as String?,
      subcategory: json['subcategory'] as String?,
      faviconUrl: json['favicon_url'] as String?,
      tags: tags,
      websiteType: json['website_type'] as String? ?? 'Free',
      source: json['source'] as String? ?? 'FMHY',
      isBookmarked: isBm,
      dateAdded: json['date_added'] as String? ?? now,
      lastUpdated: json['last_updated'] as String? ?? now,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DatabaseConstants.colId: id,
      DatabaseConstants.colName: name,
      DatabaseConstants.colUrl: url,
      DatabaseConstants.colDescription: description,
      DatabaseConstants.colCategoryId: categoryId,
      DatabaseConstants.colSubcategory: subcategory,
      DatabaseConstants.colFaviconUrl: faviconUrl,
      DatabaseConstants.colTags: jsonEncode(tags),
      DatabaseConstants.colWebsiteType: websiteType,
      DatabaseConstants.colSource: source,
      DatabaseConstants.colIsBookmarked: isBookmarked ? 1 : 0,
      DatabaseConstants.colDateAdded: dateAdded,
      DatabaseConstants.colLastUpdated: lastUpdated,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'description': description,
      'category_id': categoryId,
      'category_name': categoryName,
      'subcategory': subcategory,
      'favicon_url': faviconUrl,
      'tags': tags,
      'website_type': websiteType,
      'source': source,
      'is_bookmarked': isBookmarked,
      'date_added': dateAdded,
      'last_updated': lastUpdated,
    };
  }

  factory WebsiteModel.fromEntity(WebsiteEntity entity) {
    return WebsiteModel(
      id: entity.id,
      name: entity.name,
      url: entity.url,
      description: entity.description,
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      subcategory: entity.subcategory,
      faviconUrl: entity.faviconUrl,
      tags: entity.tags,
      websiteType: entity.websiteType,
      source: entity.source,
      isBookmarked: entity.isBookmarked,
      dateAdded: entity.dateAdded,
      lastUpdated: entity.lastUpdated,
    );
  }
}
