import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:freehub/core/theme/app_theme.dart';
import 'package:freehub/core/utils/date_utils.dart';
import 'package:freehub/domain/entities/website_entity.dart';
import 'package:freehub/presentation/providers/category_providers.dart';
import 'package:freehub/presentation/providers/database_providers.dart';
import 'package:freehub/presentation/providers/website_providers.dart';
import 'package:freehub/presentation/screens/add_website/add_website_screen.dart';

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
                style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)),
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
              final updated = await ref
                  .read(websiteControllerProvider)
                  .toggleBookmark(site.id!);
              setState(() => _website = updated);
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
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 64,
                      height: 64,
                      color: colorScheme.surfaceContainerHighest,
                      child: site.faviconUrl != null
                          ? Image.network(
                              site.faviconUrl!,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  site.name.isNotEmpty
                                      ? site.name[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    fontSize: 24,
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
                                  fontSize: 24,
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
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    site.domain,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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
                          gradient: site.isOpenSource
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    colorScheme.primary.withValues(alpha: 0.15),
                                    colorScheme.primary.withValues(alpha: 0.08),
                                  ],
                                )
                              : null,
                          color: site.isOpenSource
                              ? null
                              : site.isFree
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          site.websiteType,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: site.isOpenSource
                                ? colorScheme.primary
                                : site.isFree
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: site.isCustom
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.blue.withValues(alpha: 0.15),
                                    Colors.blue.withValues(alpha: 0.08),
                                  ],
                                )
                              : null,
                          color: site.isCustom
                              ? null
                              : Colors.teal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          site.source,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: site.isCustom
                                ? Colors.blue.shade700
                                : Colors.teal.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // Primary button: In-App Browser on Mobile, Direct Browser on Web/Desktop
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            ref
                                .read(websiteControllerProvider)
                                .recordVisit(site.id!);
                            _openResource(site);
                          },
                          icon: Icon(isMobile
                              ? Icons.chrome_reader_mode_outlined
                              : Icons.open_in_new_rounded),
                          label: Text(
                              isMobile ? 'Open In-App' : 'Open Resource'),
                        ),
                      ),
                      if (isMobile) ...[
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.open_in_new_rounded),
                          tooltip: 'Open in External Browser',
                          onPressed: () {
                            ref
                                .read(websiteControllerProvider)
                                .recordVisit(site.id!);
                            _openExternalBrowser(site.url);
                          },
                        ),
                      ],
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.copy_rounded),
                        tooltip: 'Copy URL',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: site.url));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('URL copied to clipboard!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
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
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  site.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
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
                if (site.subcategory != null && site.subcategory!.isNotEmpty) ...[
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
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: site.tags.map((tag) {
                    return Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.primary.withValues(alpha: 0.1),
                            colorScheme.primary.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
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

    return GestureDetector(
      onTap: () {
        // Optional: scroll to section
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.15),
                    colorScheme.primary.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.label_important_outlined,
                size: 16,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid resource URL')),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to open URL: $e')),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context, WebsiteEntity site) {
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

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
        content: Text('Are you sure you want to permanently remove "${site.name}"?\n\nThis action cannot be undone.'),
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
              messenger.showSnackBar(
                SnackBar(content: Text('Removed "${site.name}"')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}