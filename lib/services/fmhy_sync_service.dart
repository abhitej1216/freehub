import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../core/utils/date_utils.dart';
import '../data/models/category_model.dart';
import '../data/models/website_model.dart';
import 'import_export_service.dart';

class FmhySyncResult {
  final int totalFetched;
  final int newAdded;
  final int updated;
  final int skipped;
  final bool success;
  final String message;

  const FmhySyncResult({
    required this.totalFetched,
    required this.newAdded,
    required this.updated,
    required this.skipped,
    required this.success,
    required this.message,
  });
}

/// Service that queries official FMHY GitHub repository documentation files in real time,
/// parses new/updated resources, and syncs them into FreeHub SQLite storage.
class FmhySyncService {
  final ImportExportService _importExportService;
  final http.Client _client;

  static const String _rawBaseUrl =
      'https://raw.githubusercontent.com/fmhy/edit/main/docs';

  static const Map<String, Map<String, String>> categoryMapping = {
    'ai.md': {
      'name': 'Artificial Intelligence',
      'description': 'AI tools, chatbots, image generators, and ML resources',
      'icon': 'ai',
    },
    'video.md': {
      'name': 'Streaming',
      'description': 'Video streaming, movies, TV shows, and anime',
      'icon': 'streaming',
    },
    'audio.md': {
      'name': 'Listening / Music',
      'description': 'Music streaming, audiobooks, and podcasts',
      'icon': 'music',
    },
    'gaming.md': {
      'name': 'Gaming',
      'description': 'Free games, emulators, game mods, and gaming tools',
      'icon': 'gaming',
    },
    'reading.md': {
      'name': 'Reading',
      'description': 'Books, articles, comics, manga, and magazines',
      'icon': 'reading',
    },
    'downloading.md': {
      'name': 'Downloading',
      'description': 'Direct download sources for software, games, and media',
      'icon': 'downloading',
    },
    'torrenting.md': {
      'name': 'Torrenting',
      'description': 'Torrent clients, trackers, search engines, and indexers',
      'icon': 'torrenting',
    },
    'educational.md': {
      'name': 'Educational',
      'description': 'Free courses, tutorials, textbooks, and learning tools',
      'icon': 'educational',
    },
    'mobile.md': {
      'name': 'Android / iOS',
      'description': 'Free mobile apps, open-source tools, and APK sources',
      'icon': 'android',
    },
    'linux-macos.md': {
      'name': 'Linux / macOS',
      'description': 'Desktop open-source applications and operating system tools',
      'icon': 'linux',
    },
    'privacy.md': {
      'name': 'Privacy & Security',
      'description': 'Ad blockers, VPNs, encrypted messaging, and security',
      'icon': 'privacy',
    },
    'developer-tools.md': {
      'name': 'Development Tools',
      'description': 'APIs, hosting, free databases, web dev tools, and IDEs',
      'icon': 'development',
    },
    'image-tools.md': {
      'name': 'Design & Graphics',
      'description': 'Free image editors, stock photos, icons, and graphic design tools',
      'icon': 'design',
    },
    'internet-tools.md': {
      'name': 'Productivity',
      'description': 'Online utilities, search engines, and productivity tools',
      'icon': 'productivity',
    },
    'misc.md': {
      'name': 'Miscellaneous',
      'description': 'Other interesting, useful, and unique free internet resources',
      'icon': 'miscellaneous',
    },
  };

  static final RegExp _linkRegex = RegExp(
    r'^\s*[\*\-]\s*(?<star>⭐\s*)?(?:\*\*)?\[(?<name>[^\]]+)\]\((?<url>https?://[^\s\)]+)\)(?:\*\*)?(?:\s*[-–—]\s*(?<desc>.*))?',
    multiLine: true,
  );

  static final RegExp _headingRegex =
      RegExp(r'^(?:#|##|###)\s*(?:►|▷)?\s*(?<title>.+)$');

  FmhySyncService(
    this._importExportService, [
    http.Client? client,
  ]) : _client = client ?? http.Client();

  /// Fetches the selected or all categories from the official FMHY GitHub repository,
  /// builds an ImportPreview, and merges it into SQLite.
  Future<FmhySyncResult> syncFromGithub({
    void Function(String status, double progress)? onProgress,
    int maxPerCategory = 35,
    bool updateExisting = false,
  }) async {
    final categoriesToImport = <CategoryModel>[];
    final websitesToImport = <WebsiteModel>[];
    final entries = categoryMapping.entries.toList();
    int fetchedFiles = 0;

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final slug = entry.key;
      final info = entry.value;
      final catName = info['name']!;

      onProgress?.call(
        'Fetching $catName...',
        i / entries.length,
      );

      categoriesToImport.add(
        CategoryModel(
          name: catName,
          description: info['description'],
          icon: info['icon'],
        ),
      );

      try {
        final uri = Uri.parse('$_rawBaseUrl/$slug');
        final response = await _client.get(
          uri,
          headers: {'User-Agent': 'FreeHub-Directory-App/1.0'},
        );

        if (response.statusCode == 200) {
          final markdown = utf8.decode(response.bodyBytes);
          final sites = parseMarkdownToWebsites(
            markdown,
            catName,
            maxPerCategory: maxPerCategory,
          );
          websitesToImport.addAll(sites);
          fetchedFiles++;
        } else {
          debugPrint('Failed to fetch $slug: HTTP ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('Error fetching $slug: $e');
      }
    }

    if (fetchedFiles == 0 || websitesToImport.isEmpty) {
      return const FmhySyncResult(
        totalFetched: 0,
        newAdded: 0,
        updated: 0,
        skipped: 0,
        success: false,
        message: 'Could not connect to GitHub or no content was fetched. Please check your internet connection.',
      );
    }

    onProgress?.call('Analyzing database differences...', 0.95);

    // Build the ImportPreview object using toJson() for standard export schema serialization
    final now = AppDateUtils.now();
    final jsonDataset = {
      'app': AppConstants.appName,
      'schemaVersion': 1,
      'exportedAt': now,
      'categories': categoriesToImport.map((c) => c.toJson()).toList(),
      'websites': websitesToImport.map((w) => w.toJson()).toList(),
    };

    final jsonString = jsonEncode(jsonDataset);
    final preview = await _importExportService.previewJsonString(jsonString);

    if (!preview.isValid) {
      return FmhySyncResult(
        totalFetched: websitesToImport.length,
        newAdded: 0,
        updated: 0,
        skipped: 0,
        success: false,
        message: preview.errorMessage ?? 'Invalid sync payload',
      );
    }

    onProgress?.call('Writing updates to SQLite...', 0.98);

    final result = await _importExportService.executeImport(
      preview,
      updateExisting: updateExisting,
      keepCustomWebsites: true,
    );

    return FmhySyncResult(
      totalFetched: websitesToImport.length,
      newAdded: result.importedCount,
      updated: result.updatedCount,
      skipped: result.skippedCount,
      success: result.success,
      message: 'Sync complete! ${result.importedCount} new resources added, ${result.updatedCount} updated, ${result.skippedCount} unchanged.',
    );
  }

  /// Parses raw markdown lines into normalized WebsiteModel objects.
  static List<WebsiteModel> parseMarkdownToWebsites(
    String markdown,
    String categoryName, {
    int maxPerCategory = 35,
  }) {
    final websites = <WebsiteModel>[];
    String currentSubcategory = 'General';
    final seenUrls = <String>{};
    final nowIso = AppDateUtils.now();

    for (final rawLine in markdown.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      final headingMatch = _headingRegex.firstMatch(line);
      if (headingMatch != null) {
        final rawTitle = headingMatch.namedGroup('title')?.trim() ?? '';
        final cleanTitle =
            rawTitle.replaceAll(RegExp(r'^[►▷\*\#\s]+'), '').trim();
        if (cleanTitle.isNotEmpty && !cleanTitle.startsWith('Back to')) {
          currentSubcategory = cleanTitle;
        }
        continue;
      }

      final linkMatch = _linkRegex.firstMatch(line);
      if (linkMatch != null) {
        final name = linkMatch.namedGroup('name')?.trim() ?? '';
        final url = linkMatch.namedGroup('url')?.trim() ?? '';
        final desc = linkMatch.namedGroup('desc')?.trim();
        final isStarred = (linkMatch.namedGroup('star') ?? '').isNotEmpty;

        final normalizedUrl = url.endsWith('/')
            ? url.substring(0, url.length - 1)
            : url;

        if (seenUrls.contains(normalizedUrl.toLowerCase())) continue;
        seenUrls.add(normalizedUrl.toLowerCase());

        // Skip internal/meta links
        if (url.contains('reddit.com') ||
            (url.contains('github.com/fmhy') && url.contains('edit'))) {
          continue;
        }

        String? cleanDesc;
        if (desc != null && desc.isNotEmpty) {
          cleanDesc = desc
              .replaceAll(RegExp(r'\[([^\]]+)\]\([^\)]+\)'), r'$1')
              .replaceAll(RegExp(r'[\*\`]+'), '')
              .trim();
        }

        String websiteType = AppConstants.typeFree;
        final tags = <String>[categoryName.toLowerCase().split(' ').first];

        if (isStarred) {
          tags.add('popular');
        }

        if (cleanDesc != null) {
          final descLower = cleanDesc.toLowerCase();
          if (descLower.contains('open-source') ||
              descLower.contains('github') ||
              descLower.contains('open source')) {
            websiteType = AppConstants.typeOpenSource;
            tags.add('open-source');
          } else if (descLower.contains('freemium') ||
              descLower.contains('trial') ||
              descLower.contains('free tier')) {
            websiteType = AppConstants.typeFreemium;
          } else if (descLower.contains('paid')) {
            websiteType = 'Paid';
          } else if (descLower.contains('free')) {
            websiteType = AppConstants.typeFree;
          }
        }

        Uri? parsedUri = Uri.tryParse(url);
        final domain = parsedUri?.host.replaceFirst('www.', '') ?? '';

        websites.add(
          WebsiteModel(
            name: name,
            url: url,
            description: (cleanDesc != null && cleanDesc.isNotEmpty)
                ? cleanDesc
                : 'Free resource in $categoryName',
            categoryName: categoryName,
            subcategory: currentSubcategory,
            faviconUrl: domain.isNotEmpty
                ? '${AppConstants.faviconBaseUrl}$domain'
                : null,
            tags: tags.toSet().toList(),
            websiteType: websiteType,
            source: AppConstants.sourceFmhy,
            isBookmarked: isStarred,
            dateAdded: nowIso,
            lastUpdated: nowIso,
          ),
        );

        if (websites.length >= maxPerCategory) {
          break;
        }
      }
    }

    return websites;
  }
}
