import 'package:flutter/material.dart';
import '../../domain/entities/website_entity.dart';

class WebsiteCard extends StatelessWidget {
  final WebsiteEntity website;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkToggle;
  final bool compact;

  const WebsiteCard({
    super.key,
    required this.website,
    this.onTap,
    this.onBookmarkToggle,
    this.compact = false,
  });

  Color _getTypeColor(String type, BuildContext context) {
    switch (type.toLowerCase()) {
      case 'open source':
        return const Color(0xFF4CAF50);
      case 'freemium':
        return const Color(0xFFFF9800);
      case 'free':
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final typeColor = _getTypeColor(website.websiteType, context);
    final isDark = theme.brightness == Brightness.dark;

    if (compact) {
      return Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.4),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFavicon(size: 32, typeColor: typeColor),
                    if (onBookmarkToggle != null)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) => ScaleTransition(
                          scale: animation,
                          child: child,
                        ),
                        child: IconButton(
                          key: ValueKey(website.isBookmarked),
                          icon: Icon(
                            website.isBookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            size: 20,
                            color: website.isBookmarked
                                ? colorScheme.primary
                                : colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          visualDensity: VisualDensity.compact,
                          onPressed: onBookmarkToggle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      website.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      website.domain,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            typeColor.withValues(alpha: 0.15),
                            typeColor.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        website.websiteType,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: typeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFavicon(size: 40, typeColor: typeColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            website.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                typeColor.withValues(alpha: 0.15),
                                typeColor.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            website.websiteType,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: typeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      website.domain,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    if (website.description != null &&
                        website.description!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        website.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                        ),
                      ),
                    ],
                    if (website.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: website.tags.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: colorScheme.primary.withValues(alpha: 0.2),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              '#$tag',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              if (onBookmarkToggle != null)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                  child: IconButton(
                    key: ValueKey('bookmark-${website.isBookmarked}'),
                    icon: Icon(
                      website.isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      size: 22,
                      color: website.isBookmarked
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    onPressed: onBookmarkToggle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavicon({required double size, required Color typeColor}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        website.effectiveFaviconUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  typeColor.withValues(alpha: 0.2),
                  typeColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                website.name.isNotEmpty ? website.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: size * 0.45,
                  fontWeight: FontWeight.w700,
                  color: typeColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}