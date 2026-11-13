extension StringExtensions on String {
  String get capitalizeFirst {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get capitalizeWords {
    return split(' ').map((word) => word.capitalizeFirst).join(' ');
  }

  bool get isValidUrl {
    final uri = Uri.tryParse(this);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  String get domainFromUrl {
    final uri = Uri.tryParse(this);
    if (uri == null) return this;
    return uri.host.replaceFirst('www.', '');
  }

  String get websiteNameFromUrl {
    final domain = domainFromUrl;
    final parts = domain.split('.');
    if (parts.isEmpty) return domain;
    return parts.first.capitalizeFirst;
  }

  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  List<String> get tagsFromJson {
    try {
      // Simple JSON array parsing without json package dependency in extensions
      final cleaned = trim();
      if (cleaned.startsWith('[') && cleaned.endsWith(']')) {
        final inner = cleaned.substring(1, cleaned.length - 1);
        if (inner.trim().isEmpty) return [];
        return inner
            .split(',')
            .map((s) => s.trim().replaceAll('"', '').replaceAll("'", ''))
            .where((s) => s.isNotEmpty)
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}

extension NullableStringExtensions on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  String get orEmpty => this ?? '';
}
