import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:freehub/core/constants/app_constants.dart';
import 'package:freehub/core/theme/app_motion.dart';
import 'package:freehub/domain/entities/website_entity.dart';
import 'package:freehub/presentation/providers/database_providers.dart';
import 'package:freehub/presentation/providers/website_providers.dart';
import 'package:freehub/presentation/widgets/empty_state.dart';
import 'package:freehub/presentation/widgets/emil_pressable.dart';
import 'package:freehub/presentation/widgets/emil_stagger.dart';
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
    final colorScheme = theme.colorScheme;
    final websiteController = ref.read(websiteControllerProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Search websites, tools, tags...',
            hintStyle: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.45),
              fontWeight: FontWeight.w400,
            ),
            fillColor: Colors.transparent,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
            suffixIcon: _query.isNotEmpty
                ? EmilPressable(
                    scaleOnPress: 0.88,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _controller.clear();
                      setState(() => _query = '');
                      _executeSearch();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.clear_rounded,
                        size: 18,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
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
          // Filter Chips Horizontal Bar with Emil tactile response
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Free',
                  selected: _selectedType == AppConstants.typeFree,
                  color: const Color(0xFF10B981),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedType = _selectedType == AppConstants.typeFree
                          ? null
                          : AppConstants.typeFree;
                    });
                    _executeSearch();
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Open Source',
                  selected: _selectedType == AppConstants.typeOpenSource,
                  color: const Color(0xFF06B6D4),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedType =
                          _selectedType == AppConstants.typeOpenSource
                              ? null
                              : AppConstants.typeOpenSource;
                    });
                    _executeSearch();
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Freemium',
                  selected: _selectedType == AppConstants.typeFreemium,
                  color: const Color(0xFFF59E0B),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedType = _selectedType == AppConstants.typeFreemium
                          ? null
                          : AppConstants.typeFreemium;
                    });
                    _executeSearch();
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Bookmarked',
                  selected: _isBookmarked == true,
                  color: colorScheme.primary,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _isBookmarked = _isBookmarked == true ? null : true;
                    });
                    _executeSearch();
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Custom Added',
                  selected: _isCustom == true,
                  color: colorScheme.secondary,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _isCustom = _isCustom == true ? null : true;
                    });
                    _executeSearch();
                  },
                ),
              ],
            ),
          ),

          // Search Results Counter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Text(
                  '${_results.length} resources found',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w600,
                  ),
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
                        title: 'No Matches Found',
                        message:
                            'Try adjusting your search keywords or clearing active filters.',
                      )
                    : ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final website = _results[index];
                          return EmilStaggerItem(
                            index: index,
                            child: WebsiteCard(
                              website: website,
                              onTap: () {
                                if (website.id != null) {
                                  websiteController.recordVisit(website.id!);
                                }
                                context.push('/website/${website.id}',
                                    extra: website);
                              },
                              onBookmarkToggle: () =>
                                  websiteController.toggleBookmark(website.id!),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return EmilPressable(
      scaleOnPress: 0.93,
      duration: AppMotion.durationPress,
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.durationFast,
        curve: AppMotion.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.16)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? color
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
            width: selected ? 1.4 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? color
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
