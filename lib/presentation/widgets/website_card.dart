import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_motion.dart';
import '../../domain/entities/website_entity.dart';
import 'emil_pressable.dart';

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

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'open source':
        return const Color(0xFF06B6D4); // Cyan
      case 'freemium':
        return const Color(0xFFF59E0B); // Amber
      case 'free':
      default:
        return const Color(0xFF10B981); // Emerald
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final typeColor = _getTypeColor(website.websiteType);
    final isDark = theme.brightness == Brightness.dark;

    if (compact) {
      return Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        child: EmilPressable(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
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
                    _buildFavicon(size: 34, typeColor: typeColor, isDark: isDark),
                    if (onBookmarkToggle != null)
                      _buildBookmarkButton(colorScheme),
                  ],
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      website.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      website.domain,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTypeBadge(typeColor),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: EmilPressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.55),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.05),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFavicon(size: 42, typeColor: typeColor, isDark: isDark),
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
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildTypeBadge(typeColor),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      website.domain,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.55),
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
                          height: 1.4,
                        ),
                      ),
                    ],
                    if (website.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 5,
                        runSpacing: 4,
                        children: website.tags.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: colorScheme.primary.withValues(alpha: 0.18),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              '#$tag',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              if (onBookmarkToggle != null) ...[
                const SizedBox(width: 4),
                _buildBookmarkButton(colorScheme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBadge(Color typeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: typeColor.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Text(
        website.websiteType,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: typeColor,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildBookmarkButton(ColorScheme colorScheme) {
    return EmilPressable(
      scaleOnPress: 0.88,
      duration: AppMotion.durationPress,
      onTap: () {
        HapticFeedback.selectionClick();
        onBookmarkToggle?.call();
      },
      child: AnimatedSwitcher(
        duration: AppMotion.durationFast,
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: child,
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            website.isBookmarked
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            key: ValueKey('bm-${website.isBookmarked}'),
            size: 22,
            color: website.isBookmarked
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }

  Widget _buildFavicon({
    required double size,
    required Color typeColor,
    required bool isDark,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF262C38) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Image.network(
          website.effectiveFaviconUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size,
              height: size,
              color: typeColor.withValues(alpha: 0.12),
              child: Center(
                child: Text(
                  website.name.isNotEmpty ? website.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: size * 0.44,
                    fontWeight: FontWeight.w700,
                    color: typeColor,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
