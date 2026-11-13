class WebsiteEntity {
  final int? id;
  final String name;
  final String url;
  final String? description;
  final int? categoryId;
  final String? categoryName;
  final String? subcategory;
  final String? faviconUrl;
  final List<String> tags;
  final String websiteType;
  final String source;
  final bool isBookmarked;
  final String dateAdded;
  final String lastUpdated;

  const WebsiteEntity({
    this.id,
    required this.name,
    required this.url,
    this.description,
    this.categoryId,
    this.categoryName,
    this.subcategory,
    this.faviconUrl,
    this.tags = const [],
    this.websiteType = 'Free',
    this.source = 'CUSTOM',
    this.isBookmarked = false,
    required this.dateAdded,
    required this.lastUpdated,
  });

  String get domain {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (_) {
      return url;
    }
  }

  String get effectiveFaviconUrl {
    if (faviconUrl != null && faviconUrl!.isNotEmpty) return faviconUrl!;
    return 'https://www.google.com/s2/favicons?sz=64&domain=$domain';
  }

  bool get isCustom => source == 'CUSTOM';
  bool get isFmhy => source == 'FMHY';
  bool get isFree => websiteType == 'Free';
  bool get isFreemium => websiteType == 'Freemium';
  bool get isOpenSource => websiteType == 'Open Source';

  WebsiteEntity copyWith({
    int? id,
    String? name,
    String? url,
    String? description,
    int? categoryId,
    String? categoryName,
    String? subcategory,
    String? faviconUrl,
    List<String>? tags,
    String? websiteType,
    String? source,
    bool? isBookmarked,
    String? dateAdded,
    String? lastUpdated,
  }) {
    return WebsiteEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      subcategory: subcategory ?? this.subcategory,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      tags: tags ?? this.tags,
      websiteType: websiteType ?? this.websiteType,
      source: source ?? this.source,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      dateAdded: dateAdded ?? this.dateAdded,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebsiteEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'WebsiteEntity(id: $id, name: $name, url: $url)';
}
