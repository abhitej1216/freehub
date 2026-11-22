import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:freehub/domain/entities/website_entity.dart';
import 'package:freehub/domain/usecases/get_websites_usecase.dart';
import 'package:freehub/presentation/providers/database_providers.dart';
import 'package:freehub/presentation/providers/website_providers.dart';
import 'package:freehub/presentation/widgets/empty_state.dart';
import 'package:freehub/presentation/widgets/emil_stagger.dart';
import 'package:freehub/presentation/widgets/website_card.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkedAsync = ref.watch(bookmarkedWebsitesProvider);
    final websiteController = ref.read(websiteControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
      ),
      body: bookmarkedAsync.when(
        data: (allBookmarked) {
          if (allBookmarked.isEmpty) {
            return EmptyState(
              icon: Icons.bookmark_border_rounded,
              title: 'No Bookmarks Yet',
              message:
                  'Tap the bookmark icon on any website to save it for quick offline access.',
              actionLabel: 'Browse Categories',
              onAction: () => context.go('/categories'),
            );
          }

          return _BookmarksBody(
            allBookmarked: allBookmarked,
            onRefresh: () async {
              websiteController.refreshAll();
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _BookmarksBody extends ConsumerStatefulWidget {
  final List<WebsiteEntity> allBookmarked;
  final Future<void> Function() onRefresh;

  const _BookmarksBody({
    required this.allBookmarked,
    required this.onRefresh,
  });

  @override
  ConsumerState<_BookmarksBody> createState() => _BookmarksBodyState();
}

class _BookmarksBodyState extends ConsumerState<_BookmarksBody> {
  final TextEditingController _searchController = TextEditingController();
  String _filter = '';
  WebsiteSort _sort = WebsiteSort.alphabetical;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final useCase = ref.read(getWebsitesUseCaseProvider);
    final websiteController = ref.read(websiteControllerProvider);

    final sorted = useCase.sortBookmarks(widget.allBookmarked, _filter, _sort);

    return Column(
      children: [
        // Sort control
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _buildSortControl(theme),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _filter = val),
            decoration: InputDecoration(
              hintText: 'Search bookmarks (${sorted.length})...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _filter.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _filter = '');
                      },
                    )
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final website = sorted[index];
                return EmilStaggerItem(
                  index: index,
                  child: WebsiteCard(
                    website: website,
                    onTap: () {
                      if (website.id != null) {
                        websiteController.recordVisit(website.id!);
                      }
                      context.push('/website/${website.id}', extra: website);
                    },
                    onBookmarkToggle: () =>
                        websiteController.toggleBookmark(website.id!),
                  ),
                );
              },
            ),
          ),
        ),
      ],
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
        HapticFeedback.selectionClick();
        setState(() => _sort = selected.first);
      },
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor:
            theme.colorScheme.primary.withValues(alpha: 0.15),
        foregroundColor: theme.colorScheme.onSurface,
        selectedForegroundColor: theme.colorScheme.primary,
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
