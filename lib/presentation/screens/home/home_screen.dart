import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:freehub/core/constants/app_constants.dart';
import 'package:freehub/domain/entities/website_entity.dart';
import 'package:freehub/presentation/providers/category_providers.dart';
import 'package:freehub/presentation/providers/website_providers.dart';
import 'package:freehub/presentation/widgets/category_card.dart';
import 'package:freehub/presentation/widgets/empty_state.dart';
import 'package:freehub/presentation/widgets/section_header.dart';
import 'package:freehub/presentation/widgets/stat_card.dart';
import 'package:freehub/presentation/widgets/website_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statsAsync = ref.watch(dashboardStatsProvider);
    final recentlyAddedAsync = ref.watch(recentlyAddedWebsitesProvider);
    final recentlyVisitedAsync = ref.watch(recentlyVisitedWebsitesProvider);
    final bookmarkedAsync = ref.watch(bookmarkedWebsitesProvider);
    final popularCategories = ref.watch(popularCategoriesProvider);
    final websiteController = ref.read(websiteControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            websiteController.refreshAll();
          },
          color: colorScheme.primary,
          backgroundColor: colorScheme.surface,
          child: CustomScrollView(
            slivers: [
              // 1. App Bar with FreeHub branding & Search trigger
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      colorScheme.primary.withValues(alpha: 0.85),
                                      colorScheme.primary.withValues(alpha: 0.65),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.hub_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppConstants.appName,
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  Text(
                                    'Free Internet Resources',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: colorScheme.surfaceContainerLow,
                              foregroundColor: colorScheme.onSurface,
                            ),
                            onPressed: () => context.go('/settings'),
                            icon: const Icon(Icons.settings_outlined),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Search Bar Trigger
                      GestureDetector(
                        onTap: () => context.push('/search'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: colorScheme.outline.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search_rounded,
                                color: colorScheme.primary,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Search websites, tools, tags...',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
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
                                child: Icon(
                                  Icons.tune_rounded,
                                  size: 16,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Metrics / Stat Cards Grid
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: statsAsync.when(
                    data: (stats) => Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                context: context,
                                title: 'Websites',
                                value: '${stats.totalWebsites}',
                                icon: Icons.language_rounded,
                                onTap: () => context.go('/categories'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildStatCard(
                                context: context,
                                title: 'Categories',
                                value: '${stats.totalCategories}',
                                icon: Icons.grid_view_rounded,
                                color: colorScheme.secondary,
                                onTap: () => context.go('/categories'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildStatCard(
                                context: context,
                                title: 'Bookmarks',
                                value: '${stats.totalBookmarks}',
                                icon: Icons.bookmark_rounded,
                                color: const Color(0xFFFF9800),
                                onTap: () => context.go('/bookmarks'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                context: context,
                                title: 'Visited',
                                value: '${stats.recentlyVisitedCount}',
                                icon: Icons.access_time_rounded,
                                color: AppTheme.categoryColors[2],
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildStatCard(
                                context: context,
                                title: 'Added',
                                value: '${stats.recentlyAddedCount}',
                                icon: Icons.add_circle_outline_rounded,
                                color: AppTheme.categoryColors[4],
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    loading: () => const SizedBox(height: 140),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),
              ),

              // 3. Popular Categories
              if (popularCategories.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Categories',
                    subtitle: 'Browse by topic',
                    actionLabel: 'View All',
                    icon: Icons.category_outlined,
                    onAction: () => context.go('/categories'),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 160,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: popularCategories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final cat = popularCategories[index];
                        return SizedBox(
                          width: 160,
                          child: CategoryCard(
                            category: cat,
                            compact: true,
                            onTap: () => context.push('/category/${cat.id}',
                                extra: cat.name),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 24),
                ),
              ],

              // 4. Recently Visited Carousel
              ...recentlyVisitedAsync.maybeWhen(
                data: (visited) {
                  if (visited.isEmpty) return [];
                  return [
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 8),
                    ),
                    const SliverToBoxAdapter(
                      child: SectionHeader(
                        title: 'Recently Visited',
                        icon: Icons.history_rounded,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 165,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: visited.length,
                          itemBuilder: (context, index) {
                            final site = visited[index];
                            return SizedBox(
                              width: 260,
                              child: WebsiteCard(
                                website: site,
                                compact: true,
                                onTap: () => _openWebsite(context, site, ref),
                                onBookmarkToggle: () =>
                                    websiteController.toggleBookmark(site.id!),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ];
                },
                orElse: () => [],
              ),

              // 5. Bookmarked Websites Section
              ...bookmarkedAsync.maybeWhen(
                data: (bookmarked) {
                  if (bookmarked.isEmpty) return [];
                  return [
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 24),
                    ),
                    SliverToBoxAdapter(
                      child: SectionHeader(
                        title: 'Favourites',
                        subtitle: '${bookmarked.length} saved',
                        actionLabel: 'See All',
                        icon: Icons.star_border_rounded,
                        onAction: () => context.go('/bookmarks'),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 165,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: bookmarked.length,
                          itemBuilder: (context, index) {
                            final site = bookmarked[index];
                            return SizedBox(
                              width: 260,
                              child: WebsiteCard(
                                website: site,
                                compact: true,
                                onTap: () => _openWebsite(context, site, ref),
                                onBookmarkToggle: () =>
                                    websiteController.toggleBookmark(site.id!),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ];
                },
                orElse: () => [],
              ),

              // 6. Recently Added Websites Section
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
              const SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Recently Added',
                  subtitle: 'Latest resources',
                  icon: Icons.schedule_rounded,
                ),
              ),
              recentlyAddedAsync.when(
                data: (websites) {
                  if (websites.isEmpty) {
                    return SliverToBoxAdapter(
                      child: EmptyState(
                        icon: Icons.language_rounded,
                        title: 'No Websites Yet',
                        message:
                            'Add your first free website or import resources from Settings.',
                        actionLabel: 'Add Website',
                        onAction: () => context.push('/add-website'),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final website = websites[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          child: WebsiteCard(
                            website: website,
                            onTap: () => _openWebsite(context, website, ref),
                            onBookmarkToggle: () =>
                                websiteController.toggleBookmark(website.id!),
                          ),
                        );
                      },
                      childCount: websites.length,
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
                error: (error, _) => SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Error loading websites: $error',
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    Color? color,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = color ?? colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.surface.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.25 : 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.1 : 0.05),
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColor.withValues(alpha: 0.2),
                        accentColor.withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: accentColor,
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.touch_app_rounded,
                    size: 16,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openWebsite(
      BuildContext context, WebsiteEntity website, WidgetRef ref) {
    if (website.id != null) {
      ref.read(websiteControllerProvider).recordVisit(website.id!);
    }
    context.push('/website/${website.id}', extra: website);
  }
}