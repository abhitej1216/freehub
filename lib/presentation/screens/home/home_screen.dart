import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:freehub/core/constants/app_constants.dart';
import 'package:freehub/domain/entities/website_entity.dart';
import 'package:freehub/presentation/providers/category_providers.dart';
import 'package:freehub/presentation/providers/website_providers.dart';
import 'package:freehub/presentation/widgets/category_card.dart';
import 'package:freehub/presentation/widgets/empty_state.dart';
import 'package:freehub/presentation/widgets/emil_pressable.dart';
import 'package:freehub/presentation/widgets/emil_stagger.dart';
import 'package:freehub/presentation/widgets/section_header.dart';
import 'package:freehub/presentation/widgets/stat_card.dart';
import 'package:freehub/presentation/widgets/website_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
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
                                width: 44,
                                height: 44,
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
                                child: const Icon(
                                  Icons.hub_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        AppConstants.appName,
                                        style: theme.textTheme.headlineMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.6,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981)
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color: const Color(0xFF10B981)
                                                .withValues(alpha: 0.25),
                                            width: 0.8,
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircleAvatar(
                                              radius: 3,
                                              backgroundColor:
                                                  Color(0xFF10B981),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'OFFLINE',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF10B981),
                                                letterSpacing: 0.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Free Internet Resources Directory',
                                    style:
                                        theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface
                                          .withValues(alpha: 0.55),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          EmilPressable(
                            scaleOnPress: 0.9,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              context.go('/settings');
                            },
                            child: Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colorScheme.outline
                                      .withValues(alpha: isDark ? 0.35 : 0.6),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.tune_rounded,
                                size: 20,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Search Bar Trigger with Emil tactile scale
                      EmilPressable(
                        scaleOnPress: 0.98,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.push('/search');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 13),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.outline
                                  .withValues(alpha: isDark ? 0.35 : 0.6),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: isDark ? 0.25 : 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
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
                                'Search 449+ resources, tools, tags...',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '/',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.primary,
                                  ),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: statsAsync.when(
                    data: (stats) => Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: EmilStaggerItem(
                                index: 0,
                                child: StatCard(
                                  title: 'Resources',
                                  value: '${stats.totalWebsites}',
                                  icon: Icons.language_rounded,
                                  color: colorScheme.primary,
                                  onTap: () => context.go('/categories'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: EmilStaggerItem(
                                index: 1,
                                child: StatCard(
                                  title: 'Categories',
                                  value: '${stats.totalCategories}',
                                  icon: Icons.grid_view_rounded,
                                  color: colorScheme.secondary,
                                  onTap: () => context.go('/categories'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: EmilStaggerItem(
                                index: 2,
                                child: StatCard(
                                  title: 'Bookmarks',
                                  value: '${stats.totalBookmarks}',
                                  icon: Icons.bookmark_rounded,
                                  color: const Color(0xFFF59E0B),
                                  onTap: () => context.go('/bookmarks'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    loading: () => const SizedBox(height: 100),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),
              ),

              // 3. Popular Categories Carousel
              if (popularCategories.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Categories',
                    subtitle: 'Explore curated directory topics',
                    actionLabel: 'View All',
                    icon: Icons.category_outlined,
                    onAction: () => context.go('/categories'),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 155,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: popularCategories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final cat = popularCategories[index];
                        return EmilStaggerItem(
                          index: index,
                          child: SizedBox(
                            width: 165,
                            child: CategoryCard(
                              category: cat,
                              compact: true,
                              onTap: () => context.push(
                                  '/category/${cat.id}',
                                  extra: cat.name),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),
              ],

              // 4. Recently Visited Carousel
              ...recentlyVisitedAsync.maybeWhen(
                data: (visited) {
                  if (visited.isEmpty) return [];
                  return [
                    const SliverToBoxAdapter(
                      child: SectionHeader(
                        title: 'Recently Visited',
                        subtitle: 'Quick access to your history',
                        icon: Icons.history_rounded,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 165,
                        child: ListView.builder(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: visited.length,
                          itemBuilder: (context, index) {
                            final site = visited[index];
                            return EmilStaggerItem(
                              index: index,
                              child: SizedBox(
                                width: 260,
                                child: WebsiteCard(
                                  website: site,
                                  compact: true,
                                  onTap: () =>
                                      _openWebsite(context, site, ref),
                                  onBookmarkToggle: () =>
                                      websiteController.toggleBookmark(site.id!),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 20),
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
                    SliverToBoxAdapter(
                      child: SectionHeader(
                        title: 'Saved Favourites',
                        subtitle: '${bookmarked.length} bookmarked websites',
                        actionLabel: 'See All',
                        icon: Icons.star_border_rounded,
                        onAction: () => context.go('/bookmarks'),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 165,
                        child: ListView.builder(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: bookmarked.length,
                          itemBuilder: (context, index) {
                            final site = bookmarked[index];
                            return EmilStaggerItem(
                              index: index,
                              child: SizedBox(
                                width: 260,
                                child: WebsiteCard(
                                  website: site,
                                  compact: true,
                                  onTap: () =>
                                      _openWebsite(context, site, ref),
                                  onBookmarkToggle: () =>
                                      websiteController.toggleBookmark(site.id!),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 20),
                    ),
                  ];
                },
                orElse: () => [],
              ),

              // 6. Recently Added Websites Section
              const SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Latest Directory Resources',
                  subtitle: 'Curated and offline-ready',
                  icon: Icons.bolt_rounded,
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
                            'Add your first free website or restore the FMHY catalog from Settings.',
                        actionLabel: 'Add Website',
                        onAction: () => context.push('/add-website'),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final website = websites[index];
                        return EmilStaggerItem(
                          index: index,
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

  void _openWebsite(
      BuildContext context, WebsiteEntity website, WidgetRef ref) {
    if (website.id != null) {
      ref.read(websiteControllerProvider).recordVisit(website.id!);
    }
    context.push('/website/${website.id}', extra: website);
  }
}
