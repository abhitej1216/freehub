import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:freehub/presentation/providers/category_providers.dart';
import 'package:freehub/presentation/providers/website_providers.dart';
import 'package:freehub/presentation/widgets/empty_state.dart';
import 'package:freehub/presentation/widgets/website_card.dart';

class CategoryWebsitesScreen extends ConsumerWidget {
  final int categoryId;
  final String? categoryName;

  const CategoryWebsitesScreen({
    super.key,
    required this.categoryId,
    this.categoryName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(categoryByIdProvider(categoryId));
    final websitesAsync = ref.watch(websitesByCategoryProvider(categoryId));
    final websiteController = ref.read(websiteControllerProvider);
    final displayName = categoryName ?? category?.name ?? 'Category';

    return Scaffold(
      appBar: AppBar(
        title: Text(displayName),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Website to $displayName',
            onPressed: () => context.push('/add-website', extra: categoryId),
          ),
        ],
      ),
      body: websitesAsync.when(
        data: (websites) {
          if (websites.isEmpty) {
            return EmptyState(
              icon: Icons.language_rounded,
              title: 'No Websites in $displayName',
              message:
                  'Be the first to add a useful free resource to this category.',
              actionLabel: 'Add Website',
              onAction: () => context.push('/add-website', extra: categoryId),
            );
          }

          return RefreshIndicator(
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
