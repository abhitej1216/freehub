import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:freehub/domain/entities/category_entity.dart';
import 'package:freehub/presentation/providers/category_providers.dart';
import 'package:freehub/presentation/widgets/category_card.dart';
import 'package:freehub/presentation/widgets/empty_state.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchFilter = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Add Custom Category',
            onPressed: () => _showAddCategoryDialog(context),
          ),
        ],
      ),
      body: categoriesAsync.when(
        data: (allCategories) {
          final categories = allCategories.where((c) {
            if (_searchFilter.isEmpty) return true;
            return c.name.toLowerCase().contains(_searchFilter.toLowerCase()) ||
                (c.description?.toLowerCase().contains(_searchFilter.toLowerCase()) ?? false);
          }).toList();

          if (allCategories.isEmpty) {
            return EmptyState(
              icon: Icons.category_outlined,
              title: 'No Categories Found',
              message: 'Add a new category to organize your resources.',
              actionLabel: 'Add Category',
              onAction: () => _showAddCategoryDialog(context),
            );
          }

          return Column(
            children: [
              // Search in categories
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchFilter = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search categories...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchFilter.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchFilter = '';
                              });
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),

              // Categories Grid
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(categoriesProvider.notifier).loadCategories();
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return CategoryCard(
                        category: category,
                        onTap: () => context.push(
                          '/category/${category.id}',
                          extra: category.name,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Error: $error'),
          ),
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    String selectedIcon = 'folder';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final theme = Theme.of(context);
          return AlertDialog(
            title: const Text('Add Custom Category'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Category Name *',
                      hintText: 'e.g. Design Assets, Podcasts',
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      hintText: 'Brief summary of resources',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select Icon',
                    style: theme.textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'folder',
                      'ai',
                      'streaming',
                      'music',
                      'gaming',
                      'reading',
                      'downloading',
                      'torrenting',
                      'educational',
                      'android',
                      'linux',
                      'privacy',
                      'productivity',
                      'development',
                      'design',
                      'social',
                      'finance',
                      'storage',
                    ].map((iconKey) {
                      final isSelected = selectedIcon == iconKey;
                      final iconData = CategoryEntity(name: '', icon: iconKey).iconData;
                      return InkWell(
                        onTap: () {
                          setDialogState(() {
                            selectedIcon = iconKey;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary.withValues(alpha: 0.2)
                                : theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            iconData,
                            size: 20,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;

                  try {
                    await ref.read(categoriesProvider.notifier).addCategory(
                          name: name,
                          description: descController.text.trim().isNotEmpty
                              ? descController.text.trim()
                              : null,
                          icon: selectedIcon,
                        );
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Category "$name" created')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );
  }
}
