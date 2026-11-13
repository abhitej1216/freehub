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
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
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
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.textTheme.bodySmall?.color
                                          ?.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings_outlined),
                            onPressed: () => context.go('/settings'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Search Bar Trigger
                      InkWell(
                        onTap: () => context.push('/search'),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: theme.colorScheme.outline
                                  .withValues(alpha: 0.8),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search_rounded,
                                color: theme.colorScheme.primary,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Search websites, tools, tags...',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withValues(alpha: 0.5),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.tune_rounded,
                                  size: 14,
                                  color: theme.colorScheme.primary,
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
                    data: (stats) => Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Websites',
                            value: '${stats.totalWebsites}',
                            icon: Icons.language_rounded,
                            onTap: () => context.go('/categories'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatCard(
                            title: 'Categories',
                            value: '${stats.totalCategories}',
                            icon: Icons.grid_view_rounded,
                            color: const Color(0xFF03DAC6),
                            onTap: () => context.go('/categories'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatCard(
                            title: 'Bookmarks',
                            value: '${stats.totalBookmarks}',
                            icon: Icons.bookmark_rounded,
                            color: const Color(0xFFFF9800),
                            onTap: () => context.go('/bookmarks'),
                          ),
                        ),
                      ],
                    ),
                    loading: () => const SizedBox(height: 80),
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
                    height: 48,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: popularCategories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = popularCategories[index];
                        return CategoryCard(
                          category: cat,
                          compact: true,
                          onTap: () => context.push('/category/${cat.id}',
                              extra: cat.name),
                        );
                      },
                    ),
                  ),
                ),
              ],

              // 4. Recently Visited Carousel
              ...recentlyVisitedAsync.maybeWhen(
                data: (visited) {
                  if (visited.isEmpty) return [];
                  return [
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 12),
                    ),
                    const SliverToBoxAdapter(
                      child: SectionHeader(
                        title: 'Recently Visited',
                        icon: Icons.history_rounded,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 145,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: visited.length,
                          itemBuilder: (context, index) {
                            final site = visited[index];
                            return WebsiteCard(
                              website: site,
                              compact: true,
                              onTap: () => _openWebsite(context, site, ref),
                              onBookmarkToggle: () =>
                                  websiteController.toggleBookmark(site.id!),
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
                      child: SizedBox(height: 12),
                    ),
                    SliverToBoxAdapter(
                      child: SectionHeader(
                        title: 'Favourites',
                        subtitle: '${bookmarked.length} saved',
                        actionLabel: 'See All',
                        icon: Icons.star_outline_rounded,
                        onAction: () => context.go('/bookmarks'),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 145,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: bookmarked.length,
                          itemBuilder: (context, index) {
                            final site = bookmarked[index];
                            return WebsiteCard(
                              website: site,
                              compact: true,
                              onTap: () => _openWebsite(context, site, ref),
                              onBookmarkToggle: () =>
                                  websiteController.toggleBookmark(site.id!),
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
                child: SizedBox(height: 12),
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
                        return WebsiteCard(
                          website: website,
                          onTap: () => _openWebsite(context, website, ref),
                          onBookmarkToggle: () =>
                              websiteController.toggleBookmark(website.id!),
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
                      child: Text('Error loading websites: $error'),
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

  void _openWebsite(
      BuildContext context, WebsiteEntity website, WidgetRef ref) {
    if (website.id != null) {
      ref.read(websiteControllerProvider).recordVisit(website.id!);
    }
    context.push('/website/${website.id}', extra: website);
  }
}
