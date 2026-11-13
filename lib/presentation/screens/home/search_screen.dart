import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:freehub/core/constants/app_constants.dart';
import 'package:freehub/domain/entities/website_entity.dart';
import 'package:freehub/presentation/providers/database_providers.dart';
import 'package:freehub/presentation/providers/website_providers.dart';
import 'package:freehub/presentation/widgets/empty_state.dart';
import 'package:freehub/presentation/widgets/website_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  String _query = '';
  String? _selectedType;
  bool? _isBookmarked;
  bool? _isCustom;

  List<WebsiteEntity> _results = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _executeSearch();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _executeSearch() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(websiteRepositoryProvider);
      final results = await repo.search(
        _query.trim(),
        websiteType: _selectedType,
        isBookmarked: _isBookmarked,
        isCustom: _isCustom,
      );
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final websiteController = ref.read(websiteControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search websites, tools, tags...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _query = '');
                      _executeSearch();
                    },
                  )
                : null,
          ),
          onChanged: (val) {
            setState(() => _query = val);
            _executeSearch();
          },
        ),
      ),
      body: Column(
        children: [
          // Filter Chips Horizontal Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Free'),
                  selected: _selectedType == AppConstants.typeFree,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = selected ? AppConstants.typeFree : null;
                    });
                    _executeSearch();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Open Source'),
                  selected: _selectedType == AppConstants.typeOpenSource,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType =
                          selected ? AppConstants.typeOpenSource : null;
                    });
                    _executeSearch();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Freemium'),
                  selected: _selectedType == AppConstants.typeFreemium,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType =
                          selected ? AppConstants.typeFreemium : null;
                    });
                    _executeSearch();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Bookmarked'),
                  selected: _isBookmarked == true,
                  onSelected: (selected) {
                    setState(() {
                      _isBookmarked = selected ? true : null;
                    });
                    _executeSearch();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Custom Added'),
                  selected: _isCustom == true,
                  onSelected: (selected) {
                    setState(() {
                      _isCustom = selected ? true : null;
                    });
                    _executeSearch();
                  },
                ),
              ],
            ),
          ),

          // Search Results Counter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${_results.length} resources found',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),

          // Search Results List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? const EmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'No Matching Resources',
                        message:
                            'Try different keywords or reset your filters.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final website = _results[index];
                          return WebsiteCard(
                            website: website,
                            onTap: () {
                              if (website.id != null) {
                                websiteController.recordVisit(website.id!);
                              }
                              context.push('/website/${website.id}',
                                  extra: website);
                            },
                            onBookmarkToggle: () async {
                              final updated = await websiteController
                                  .toggleBookmark(website.id!);
                              setState(() {
                                _results[index] = updated;
                              });
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
