class UrlUtils {
  UrlUtils._();

  static bool isValid(String url) {
    final uri = Uri.tryParse(url);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  static String normalize(String url) {
    String normalized = url.trim();
    if (!normalized.startsWith('http://') && !normalized.startsWith('https://')) {
      normalized = 'https://$normalized';
    }
    return normalized;
  }

  static String getDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (_) {
      return url;
    }
  }

  static String getSuggestedName(String url) {
    try {
      final domain = getDomain(url);
      final parts = domain.split('.');
      if (parts.isEmpty) return '';
      final name = parts.first;
      return name[0].toUpperCase() + name.substring(1);
    } catch (_) {
      return '';
    }
  }

  static String getFaviconUrl(String url) {
    try {
      final domain = getDomain(url);
      return 'https://www.google.com/s2/favicons?sz=64&domain=$domain';
    } catch (_) {
      return '';
    }
  }
}
