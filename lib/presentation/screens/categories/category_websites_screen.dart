import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:freehub/domain/entities/website_entity.dart';
import 'package:freehub/domain/usecases/get_websites_usecase.dart';
import 'package:freehub/presentation/providers/category_providers.dart';
import 'package:freehub/presentation/providers/database_providers.dart';
import 'package:freehub/presentation/providers/website_providers.dart';
import 'package:freehub/presentation/widgets/empty_state.dart';
import 'package:freehub/presentation/widgets/website_card.dart';

class CategoryWebsitesScreen extends ConsumerStatefulWidget {
  final int categoryId;
  final String? categoryName;

  const CategoryWebsitesScreen({
    super.key,
    required this.categoryId,
    this.categoryName,
  });

  @override
  ConsumerState<CategoryWebsitesScreen> createState() =>
      _CategoryWebsitesScreenState();
}

class _CategoryWebsitesScreenState
    extends ConsumerState<CategoryWebsitesScreen> {
  WebsiteSort _sort = WebsiteSort.alphabetical;

  /// Cached so the query is not re-issued on every parent rebuild (e.g. the
  /// bottom navigation bar switching tabs while this route stays mounted).
  /// Reassigned on refresh and sort change.
  late Future<List<WebsiteEntity>> _websitesFuture =
      _fetch();

  Future<List<WebsiteEntity>> _fetch() => ref
      .read(getWebsitesUseCaseProvider)
      .getByCategorySorted(widget.categoryId, _sort);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = ref.watch(categoryByIdProvider(widget.categoryId));
    final websiteController = ref.read(websiteControllerProvider);
    final displayName = widget.categoryName ?? category?.name ?? 'Category';

    return Scaffold(
      appBar: AppBar(
        title: Text(displayName),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Website to $displayName',
            onPressed: () => context.push('/add-website', extra: widget.categoryId),
          ),
        ],
      ),
      body: FutureBuilder<List<WebsiteEntity>>(
        future: _websitesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final websites = snapshot.data ?? [];

          if (websites.isEmpty) {
            return EmptyState(
              icon: Icons.language_rounded,
              title: 'No Websites in $displayName',
              message:
                  'Be the first to add a useful free resource to this category.',
              actionLabel: 'Add Website',
              onAction: () =>
                  context.push('/add-website', extra: widget.categoryId),
            );
          }

          return Column(
            children: [
              // Sort control
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: _buildSortControl(theme),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      _websitesFuture = _fetch();
                    });
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    itemCount: websites.length,
                    itemBuilder: (context, index) {
                      final website = websites[index];
                      return WebsiteCard(
                        website: website,
                        onTap: () {
                          if (website.id != null) {
                            websiteController.recordVisit(website.id!);
                          }
                          context.push(
                              '/website/${website.id}', extra: website);
                        },
                        onBookmarkToggle: () =>
                            websiteController.toggleBookmark(website.id!),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSortControl(ThemeData theme) {
    return SegmentedButton<WebsiteSort>(
      segments: const [
        ButtonSegment(
          value: WebsiteSort.alphabetical,
          label: Text('A-Z'),
          icon: Icon(Icons.sort_rounded, size: 16),
        ),
        ButtonSegment(
          value: WebsiteSort.recentlyAdded,
          label: Text('Newest'),
          icon: Icon(Icons.new_releases_rounded, size: 16),
        ),
        ButtonSegment(
          value: WebsiteSort.mostVisited,
          label: Text('Popular'),
          icon: Icon(Icons.trending_up_rounded, size: 16),
        ),
      ],
      selected: {_sort},
      onSelectionChanged: (selected) {
        setState(() {
          _sort = selected.first;
          _websitesFuture = _fetch();
        });
      },
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor:
            theme.colorScheme.primary.withValues(alpha: 0.15),
        foregroundColor: theme.colorScheme.onSurface,
        selectedForegroundColor: theme.colorScheme.primary,
        side: const BorderSide(color: Colors.transparent),
      ),
    );
  }
}
