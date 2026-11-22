import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:freehub/core/utils/date_utils.dart';
import 'package:freehub/domain/entities/website_entity.dart';
import 'package:freehub/presentation/providers/category_providers.dart';
import 'package:freehub/presentation/providers/database_providers.dart';
import 'package:freehub/presentation/providers/website_providers.dart';
import 'package:freehub/presentation/screens/add_website/add_website_screen.dart';
import 'package:freehub/presentation/widgets/emil_pressable.dart';
import 'package:freehub/presentation/widgets/sonner_toast.dart';

class WebsiteDetailsScreen extends ConsumerStatefulWidget {
  final int websiteId;
  final WebsiteEntity? initialWebsite;

  const WebsiteDetailsScreen({
    super.key,
    required this.websiteId,
    this.initialWebsite,
  });

  @override
  ConsumerState<WebsiteDetailsScreen> createState() =>
      _WebsiteDetailsScreenState();
}

class _WebsiteDetailsScreenState extends ConsumerState<WebsiteDetailsScreen> {
  WebsiteEntity? _website;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _website = widget.initialWebsite;
    _loadWebsite();
  }

  Future<void> _loadWebsite() async {
    try {
      final repo = ref.read(websiteRepositoryProvider);
      final site = await repo.getById(widget.websiteId);
      if (mounted) {
        setState(() {
          _website = site ?? _website;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final site = _website;

    if (_isLoading && site == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (site == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Resource')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'Website not found',
                style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
      );
    }

    final category = site.categoryId != null
        ? ref.watch(categoryByIdProvider(site.categoryId!))
        : null;

    final bool isMobile = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS);

    return Scaffold(
      appBar: AppBar(
        title: Text(site.name),
        actions: [
          IconButton(
            icon: Icon(
              site.isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: site.isBookmarked ? colorScheme.primary : null,
            ),
            tooltip: site.isBookmarked ? 'Remove Bookmark' : 'Add Bookmark',
            onPressed: () async {
              HapticFeedback.selectionClick();
              final updated = await ref
                  .read(websiteControllerProvider)
                  .toggleBookmark(site.id!);
              if (!context.mounted) return;
              setState(() => _website = updated);
              if (updated.isBookmarked) {
                SonnerToast.success(context, 'Saved to Bookmarks');
              } else {
                SonnerToast.show(
                  context,
                  message: 'Removed from Bookmarks',
                  icon: Icons.bookmark_remove_outlined,
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Resource',
            onPressed: () async {
              final updated = await Navigator.push<WebsiteEntity>(
                context,
                MaterialPageRoute(
                  builder: (_) => AddWebsiteScreen(websiteToEdit: site),
                ),
              );
              if (updated != null && mounted) {
                setState(() => _website = updated);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share',
            onPressed: () {
              Share.share(
                '${site.name} – ${site.url}\n${site.description ?? ''}',
                subject: site.name,
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'delete') {
                _confirmDelete(context, site);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Header Card with Favicon, Title, Domain, & Type Badge
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outline
                              .withValues(alpha: isDark ? 0.4 : 0.6),
                          width: 1,
                        ),
                      ),
                      child: site.faviconUrl != null
                          ? Image.network(
                              site.faviconUrl!,
                              width: 68,
                              height: 68,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  site.name.isNotEmpty
                                      ? site.name[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                site.name.isNotEmpty
                                    ? site.name[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    site.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    site.domain,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: site.isOpenSource
                              ? const Color(0xFF06B6D4).withValues(alpha: 0.12)
                              : site.isFree
                                  ? const Color(0xFF10B981)
                                      .withValues(alpha: 0.12)
                                  : const Color(0xFFF59E0B)
                                      .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: site.isOpenSource
                                ? const Color(0xFF06B6D4)
                                    .withValues(alpha: 0.3)
                                : site.isFree
                                    ? const Color(0xFF10B981)
                                        .withValues(alpha: 0.3)
                                    : const Color(0xFFF59E0B)
                                        .withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          site.websiteType,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: site.isOpenSource
                                ? const Color(0xFF06B6D4)
                                : site.isFree
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFF59E0B),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: site.isCustom
                              ? colorScheme.secondary.withValues(alpha: 0.12)
                              : const Color(0xFF3B82F6).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: site.isCustom
                                ? colorScheme.secondary.withValues(alpha: 0.3)
                                : const Color(0xFF3B82F6).withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          site.source,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: site.isCustom
                                ? colorScheme.secondary
                                : const Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      // Primary action button with Emil tactile scale
                      Expanded(
                        child: EmilPressable(
                          scaleOnPress: 0.96,
                          onTap: () {
                            ref
                                .read(websiteControllerProvider)
                                .recordVisit(site.id!);
                            _openResource(site);
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.secondary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isMobile
                                      ? Icons.chrome_reader_mode_outlined
                                      : Icons.open_in_new_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isMobile ? 'Open In-App' : 'Open Resource',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (isMobile) ...[
                        const SizedBox(width: 10),
                        EmilPressable(
                          scaleOnPress: 0.9,
                          onTap: () {
                            ref
                                .read(websiteControllerProvider)
                                .recordVisit(site.id!);
                            _openExternalBrowser(site.url);
                          },
                          child: Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: colorScheme.outline
                                    .withValues(alpha: isDark ? 0.35 : 0.6),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.open_in_new_rounded,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 10),
                      EmilPressable(
                        scaleOnPress: 0.9,
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: site.url));
                          SonnerToast.copy(
                              context, 'Resource URL copied to clipboard');
                        },
                        child: Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: colorScheme.outline
                                  .withValues(alpha: isDark ? 0.35 : 0.6),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.copy_rounded,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Description Section
          if (site.description != null && site.description!.isNotEmpty) ...[
            _buildSectionLabel(context, 'About this Resource'),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: colorScheme.outline
                      .withValues(alpha: isDark ? 0.35 : 0.6),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  site.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.55,
                    color: colorScheme.onSurface.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Category & Taxonomy Information
          _buildSectionLabel(context, 'Classification'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: colorScheme.outline
                    .withValues(alpha: isDark ? 0.35 : 0.6),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                if (category != null)
                  ListTile(
                    leading: Icon(
                      Icons.category_outlined,
                      color: colorScheme.primary,
                    ),
                    title: const Text('Category'),
                    subtitle: Text(category.name),
                  ),
                if (site.subcategory != null &&
                    site.subcategory!.isNotEmpty) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.subdirectory_arrow_right_rounded,
                      color: colorScheme.primary,
                    ),
                    title: const Text('Subcategory'),
                    subtitle: Text(site.subcategory!),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tags
          if (site.tags.isNotEmpty) ...[
            _buildSectionLabel(context, 'Tags'),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: colorScheme.outline
                      .withValues(alpha: isDark ? 0.35 : 0.6),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: site.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.2),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Metadata & Dates
          _buildSectionLabel(context, 'Information'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: colorScheme.outline
                    .withValues(alpha: isDark ? 0.35 : 0.6),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.calendar_today_outlined,
                    color: colorScheme.primary,
                  ),
                  title: const Text('Date Added'),
                  subtitle: Text(AppDateUtils.toDisplay(site.dateAdded)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.update_outlined,
                    color: colorScheme.primary,
                  ),
                  title: const Text('Last Updated'),
                  subtitle: Text(AppDateUtils.toDisplay(site.lastUpdated)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String text) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.label_important_outlined,
              size: 15,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  void _openResource(WebsiteEntity site) {
    final bool isMobile = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS);

    if (isMobile) {
      String formattedUrl = site.url.trim();
      if (!formattedUrl.startsWith('http://') &&
          !formattedUrl.startsWith('https://')) {
        formattedUrl = 'https://$formattedUrl';
      }
      context.push('/browser', extra: {
        'url': formattedUrl,
        'title': site.name,
      });
    } else {
      _openExternalBrowser(site.url);
    }
  }

  Future<void> _openExternalBrowser(String url) async {
    String formattedUrl = url.trim();
    if (!formattedUrl.startsWith('http://') &&
        !formattedUrl.startsWith('https://')) {
      formattedUrl = 'https://$formattedUrl';
    }

    final uri = Uri.tryParse(formattedUrl);
    if (uri == null) {
      if (mounted) {
        SonnerToast.error(context, 'Invalid resource URL format');
      }
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );

      if (!launched) {
        await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
          webOnlyWindowName: '_blank',
        );
      }
    } catch (e) {
      if (mounted) {
        SonnerToast.error(context, 'Unable to open URL: $e');
      }
    }
  }

  void _confirmDelete(BuildContext context, WebsiteEntity site) {
    final nav = Navigator.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Website?'),
          ],
        ),
        content: Text(
            'Are you sure you want to permanently remove "${site.name}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              await ref
                  .read(websiteControllerProvider)
                  .deleteWebsite(site.id!);
              nav.pop(); // Close dialog
              nav.pop(); // Navigate back from details screen
              if (context.mounted) {
                SonnerToast.success(context, 'Removed "${site.name}"');
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
