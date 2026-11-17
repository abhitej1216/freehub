import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:freehub/core/constants/app_constants.dart';
import 'package:freehub/core/utils/url_utils.dart';
import 'package:freehub/domain/entities/website_entity.dart';
import 'package:freehub/presentation/providers/category_providers.dart';
import 'package:freehub/presentation/providers/website_providers.dart';

class AddWebsiteScreen extends ConsumerStatefulWidget {
  final int? initialCategoryId;
  final WebsiteEntity? websiteToEdit;

  const AddWebsiteScreen({
    super.key,
    this.initialCategoryId,
    this.websiteToEdit,
  });

  bool get isEditing => websiteToEdit != null;

  @override
  ConsumerState<AddWebsiteScreen> createState() => _AddWebsiteScreenState();
}

class _AddWebsiteScreenState extends ConsumerState<AddWebsiteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _descController = TextEditingController();
  final _subcategoryController = TextEditingController();
  final _tagsController = TextEditingController();
  final _faviconController = TextEditingController();

  int? _selectedCategoryId;
  String _selectedWebsiteType = AppConstants.typeFree;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      final site = widget.websiteToEdit!;
      _nameController.text = site.name;
      _urlController.text = site.url;
      _descController.text = site.description ?? '';
      _subcategoryController.text = site.subcategory ?? '';
      _tagsController.text = site.tags.join(', ');
      _faviconController.text = site.faviconUrl ?? '';
      _selectedCategoryId = site.categoryId ?? widget.initialCategoryId;
      _selectedWebsiteType = site.websiteType;
    } else {
      _selectedCategoryId = widget.initialCategoryId;
      // Listen to URL changes for auto-suggestions on new entries
      _urlController.addListener(_onUrlChanged);
    }
  }

  void _onUrlChanged() {
    if (widget.isEditing) return;
    final url = _urlController.text.trim();
    if (url.isNotEmpty && UrlUtils.isValid(url)) {
      if (_nameController.text.isEmpty) {
        final suggested = UrlUtils.getSuggestedName(url);
        if (suggested.isNotEmpty) {
          _nameController.text = suggested;
        }
      }
      if (_faviconController.text.isEmpty) {
        _faviconController.text = UrlUtils.getFaviconUrl(url);
      }
    }
  }

  @override
  void dispose() {
    _urlController.removeListener(_onUrlChanged);
    _nameController.dispose();
    _urlController.dispose();
    _descController.dispose();
    _subcategoryController.dispose();
    _tagsController.dispose();
    _faviconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Resource' : 'Add Free Resource'),
      ),
      body: categoriesAsync.when(
        data: (categories) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              children: [
                // URL Field
                TextFormField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    labelText: 'Website URL *',
                    hintText: 'https://example.com',
                    prefixIcon: const Icon(Icons.link_rounded),
                    suffixIcon: !widget.isEditing
                        ? IconButton(
                            icon: const Icon(Icons.auto_fix_high_rounded),
                            tooltip: 'Suggest Name & Favicon',
                            onPressed: _onUrlChanged,
                          )
                        : null,
                  ),
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'URL is required';
                    }
                    if (!UrlUtils.isValid(value.trim())) {
                      return 'Enter a valid URL (e.g. https://example.com)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Website Name *',
                    hintText: 'e.g. GitHub, Photopea',
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description Field
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'What is this resource useful for?',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                ),
                const SizedBox(height: 16),

                // Category Selector & Quick Add
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Category *',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        isExpanded: true,
                        items: categories.map((cat) {
                          return DropdownMenuItem<int>(
                            value: cat.id,
                            child: Text(cat.name, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => _selectedCategoryId = val);
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: IconButton.filledTonal(
                        icon: const Icon(Icons.add),
                        tooltip: 'New Category',
                        onPressed: () => _showAddCategoryDialog(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Subcategory Field
                TextFormField(
                  controller: _subcategoryController,
                  decoration: const InputDecoration(
                    labelText: 'Subcategory (Optional)',
                    hintText: 'e.g. Image Editors, Search Engines',
                    prefixIcon: Icon(Icons.subdirectory_arrow_right_rounded),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Tags Field
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (Comma separated)',
                    hintText: 'free, open-source, ai, tools',
                    prefixIcon: Icon(Icons.tag_rounded),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Custom Favicon URL
                TextFormField(
                  controller: _faviconController,
                  decoration: const InputDecoration(
                    labelText: 'Favicon URL (Optional)',
                    hintText: 'https://example.com/favicon.ico',
                    prefixIcon: Icon(Icons.image_outlined),
                  ),
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 20),

                // Website Type / License
                Text(
                  'Pricing / License Type',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: AppConstants.typeFree,
                      label: Text('Free'),
                      icon: Icon(Icons.check_circle_outline, size: 16),
                    ),
                    ButtonSegment(
                      value: AppConstants.typeFreemium,
                      label: Text('Freemium'),
                      icon: Icon(Icons.star_half_rounded, size: 16),
                    ),
                    ButtonSegment(
                      value: AppConstants.typeOpenSource,
                      label: Text('Open Source'),
                      icon: Icon(Icons.code_rounded, size: 16),
                    ),
                  ],
                  selected: {_selectedWebsiteType},
                  onSelectionChanged: (set) {
                    setState(() => _selectedWebsiteType = set.first);
                  },
                ),
                const SizedBox(height: 32),

                // Save / Update Button
                FilledButton.icon(
                  onPressed: _isSaving ? null : _saveWebsite,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(widget.isEditing ? Icons.save_rounded : Icons.add_rounded),
                  label: Text(
                    _isSaving
                        ? 'Saving...'
                        : (widget.isEditing ? 'Update Resource' : 'Save Resource'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Future<void> _saveWebsite() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final url = UrlUtils.normalize(_urlController.text.trim());
      final name = _nameController.text.trim();
      final desc = _descController.text.trim();
      final subcategory = _subcategoryController.text.trim();
      final favicon = _faviconController.text.trim();

      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim().replaceAll('#', ''))
          .where((t) => t.isNotEmpty)
          .toList();

      final now = DateTime.now().toUtc().toIso8601String();

      if (widget.isEditing) {
        final existing = widget.websiteToEdit!;
        final updatedWebsite = existing.copyWith(
          name: name,
          url: url,
          description: desc.isNotEmpty ? desc : null,
          categoryId: _selectedCategoryId,
          subcategory: subcategory.isNotEmpty ? subcategory : null,
          faviconUrl: favicon.isNotEmpty ? favicon : null,
          tags: tags,
          websiteType: _selectedWebsiteType,
          lastUpdated: now,
        );

        await ref.read(websiteControllerProvider).updateWebsite(updatedWebsite);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Updated "$name" successfully!')),
          );
          context.pop(updatedWebsite);
        }
      } else {
        final newWebsite = WebsiteEntity(
          name: name,
          url: url,
          description: desc.isNotEmpty ? desc : null,
          categoryId: _selectedCategoryId,
          subcategory: subcategory.isNotEmpty ? subcategory : null,
          faviconUrl: favicon.isNotEmpty ? favicon : null,
          tags: tags,
          websiteType: _selectedWebsiteType,
          source: AppConstants.sourceCustom,
          dateAdded: now,
          lastUpdated: now,
        );

        await ref.read(websiteControllerProvider).addWebsite(newWebsite);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Added "$name" successfully!')),
          );
          context.pop(newWebsite);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('already exists')
                  ? 'A website with this URL already exists!'
                  : 'Error saving website: $e',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Category Name',
            hintText: 'e.g. Tools, AI Tools',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final catName = nameCtrl.text.trim();
              if (catName.isEmpty) return;
              final nav = Navigator.of(ctx);
              try {
                final created = await ref
                    .read(categoriesProvider.notifier)
                    .addCategory(name: catName);
                if (mounted) {
                  setState(() {
                    _selectedCategoryId = created?.id;
                  });
                  nav.pop();
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('$e')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
