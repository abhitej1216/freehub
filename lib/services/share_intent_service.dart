import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../core/utils/url_utils.dart';

/// Structured result containing the extracted URL and optional suggested title
/// parsed from an incoming Android share intent.
class ParsedSharedData {
  final String url;
  final String? suggestedTitle;
  final String rawText;

  const ParsedSharedData({
    required this.url,
    this.suggestedTitle,
    required this.rawText,
  });

  @override
  String toString() =>
      'ParsedSharedData(url: $url, suggestedTitle: $suggestedTitle)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParsedSharedData &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          suggestedTitle == other.suggestedTitle &&
          rawText == other.rawText;

  @override
  int get hashCode =>
      url.hashCode ^ (suggestedTitle?.hashCode ?? 0) ^ rawText.hashCode;
}

/// Service that handles Android Share-Target intents (e.g. "Share" from mobile browsers).
class ShareIntentService {
  static final RegExp _urlRegex = RegExp(
    r'https?://[^\s<>"]+',
    caseSensitive: false,
  );

  static final RegExp _domainRegex = RegExp(
    r'^[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+(/[^\s]*)?$',
  );

  StreamSubscription<List<SharedMediaFile>>? _intentSub;

  /// Parses raw text shared from a browser or another app.
  ///
  /// Extracts the first valid HTTP/HTTPS URL.
  /// If the text also contained page title text or description before/after the URL,
  /// it is captured as [suggestedTitle].
  static ParsedSharedData? parseSharedText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;

    final match = _urlRegex.firstMatch(trimmed);
    if (match == null) {
      // If no explicit http/https scheme, test if trimmed is a naked domain like "example.com"
      if (!trimmed.contains(' ') &&
          _domainRegex.hasMatch(trimmed) &&
          UrlUtils.isValid(UrlUtils.normalize(trimmed))) {
        final normalized = UrlUtils.normalize(trimmed);
        return ParsedSharedData(
          url: normalized,
          suggestedTitle: UrlUtils.getSuggestedName(normalized),
          rawText: trimmed,
        );
      }
      return null;
    }

    final rawUrl = match.group(0)!;
    // Strip trailing punctuation often attached in shared text like "Check this: https://example.com."
    final cleanUrl = rawUrl.replaceAll(RegExp(r'[\.,;:\)\]\>]+$'), '');
    final normalizedUrl = UrlUtils.normalize(cleanUrl);

    if (!UrlUtils.isValid(normalizedUrl)) {
      return null;
    }

    // Extract title from the remaining text
    String remaining = trimmed.replaceFirst(rawUrl, '').trim();
    // Clean common prefixes/suffixes like "Check out this: ", quotes, brackets
    remaining = remaining
        .replaceAll(
          RegExp(
            r'^(Check out|Check this out|Look at this|Shared from)[\s:\-–—]*',
            caseSensitive: false,
          ),
          '',
        )
        .replaceAll(RegExp(r'^[\s"\-:–—\(\[]+|[\s"\-:–—\)\/\]]+$'), '')
        .trim();

    if (remaining.startsWith("'")) remaining = remaining.substring(1).trim();
    if (remaining.endsWith("'")) remaining = remaining.substring(0, remaining.length - 1).trim();

    String? suggestedTitle;
    if (remaining.isNotEmpty) {
      suggestedTitle = remaining;
    } else {
      suggestedTitle = UrlUtils.getSuggestedName(normalizedUrl);
    }

    return ParsedSharedData(
      url: normalizedUrl,
      suggestedTitle: suggestedTitle.isNotEmpty ? suggestedTitle : null,
      rawText: trimmed,
    );
  }

  /// Initializes listening for share intents.
  ///
  /// Calls [onDataReceived] when a valid URL is received either while the app
  /// was already open (stream) or when cold-started via a share intent.
  void initSharingListener({
    required void Function(ParsedSharedData data) onDataReceived,
    ReceiveSharingIntent? pluginInstance,
  }) {
    final plugin = pluginInstance ?? ReceiveSharingIntent.instance;

    // 1. Listen for shared items when app is in background/foreground (warm/hot start)
    _intentSub = plugin.getMediaStream().listen(
      (List<SharedMediaFile> files) {
        _handleMediaFiles(files, onDataReceived, plugin);
      },
      onError: (err) {
        debugPrint('ShareIntentService getMediaStream error: $err');
      },
    );

    // 2. Check for shared items if app was closed / cold-started from share sheet
    plugin.getInitialMedia().then(
      (List<SharedMediaFile> files) {
        _handleMediaFiles(files, onDataReceived, plugin);
      },
      onError: (err) {
        debugPrint('ShareIntentService getInitialMedia error: $err');
      },
    );
  }

  void _handleMediaFiles(
    List<SharedMediaFile> files,
    void Function(ParsedSharedData data) onDataReceived,
    ReceiveSharingIntent plugin,
  ) {
    if (files.isEmpty) return;

    for (final file in files) {
      // Process text or url shared types
      final content = file.path;
      final parsed = parseSharedText(content);
      if (parsed != null) {
        onDataReceived(parsed);
        // Reset the intent so it doesn't trigger again on re-entry
        plugin.reset();
        break;
      }
    }
  }

  /// Cleans up listeners and subscriptions.
  void dispose() {
    _intentSub?.cancel();
    _intentSub = null;
  }
}
