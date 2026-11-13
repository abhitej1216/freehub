import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:freehub/presentation/providers/website_providers.dart';
import 'package:freehub/presentation/widgets/empty_state.dart';
import 'package:freehub/presentation/widgets/website_card.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filter = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookmarkedAsync = ref.watch(bookmarkedWebsitesProvider);
    final websiteController = ref.read(websiteControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
      ),
      body: bookmarkedAsync.when(
        data: (allBookmarked) {
          final websites = allBookmarked.where((w) {
            if (_filter.isEmpty) return true;
            return w.name.toLowerCase().contains(_filter.toLowerCase()) ||
                w.url.toLowerCase().contains(_filter.toLowerCase()) ||
                (w.description?.toLowerCase().contains(_filter.toLowerCase()) ?? false);
          }).toList();

          if (allBookmarked.isEmpty) {
            return EmptyState(
              icon: Icons.bookmark_border_rounded,
              title: 'No Bookmarks Yet',
              message: 'Tap the bookmark icon on any website to save it for quick access.',
              actionLabel: 'Browse Categories',
              onAction: () => context.go('/categories'),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _filter = val),
                  decoration: InputDecoration(
                    hintText: 'Search bookmarks (${websites.length})...',
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
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    websiteController.refreshAll();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: websites.length,
                    itemBuilder: (context, index) {
                      final website = websites[index];
                      return WebsiteCard(
                        website: website,
                        onTap: () {
                          if (website.id != null) {
                            websiteController.recordVisit(website.id!);
                          }
                          context.push('/website/${website.id}', extra: website);
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
