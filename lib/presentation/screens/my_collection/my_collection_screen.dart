import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:freehub/presentation/providers/database_providers.dart';
import 'package:freehub/presentation/providers/website_providers.dart';
import 'package:freehub/presentation/widgets/empty_state.dart';
import 'package:freehub/presentation/widgets/website_card.dart';

final customWebsitesProvider = FutureProvider((ref) async {
  ref.watch(websiteUpdateTriggerProvider);
  final repo = ref.watch(websiteRepositoryProvider);
  return repo.search('', isCustom: true);
});

class MyCollectionScreen extends ConsumerWidget {
  const MyCollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customAsync = ref.watch(customWebsitesProvider);
    final websiteController = ref.read(websiteControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Collection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Website',
            onPressed: () => context.push('/add-website'),
          ),
        ],
      ),
      body: customAsync.when(
        data: (websites) {
          if (websites.isEmpty) {
            return EmptyState(
              icon: Icons.folder_special_outlined,
              title: 'No Custom Websites',
              message:
                  'Websites you manually add will appear here, separated from imported FMHY directory data.',
              actionLabel: 'Add Website',
              onAction: () => context.push('/add-website'),
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
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
