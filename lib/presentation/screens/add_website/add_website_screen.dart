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
  final String? initialUrl;
  final String? initialName;

  const AddWebsiteScreen({
    super.key,
    this.initialCategoryId,
    this.websiteToEdit,
    this.initialUrl,
    this.initialName,
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

      // If opened via Android Share-Target or initial parameters, pre-populate
      if (widget.initialUrl != null && widget.initialUrl!.isNotEmpty) {
        final url = widget.initialUrl!.trim();
        _urlController.text = url;
        if (widget.initialName != null && widget.initialName!.isNotEmpty) {
          _nameController.text = widget.initialName!.trim();
        } else if (UrlUtils.isValid(url)) {
          _nameController.text = UrlUtils.getSuggestedName(url);
        }
        if (UrlUtils.isValid(url)) {
          _faviconController.text = UrlUtils.getFaviconUrl(url);
        }
      }

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
        title: Text(widget.isEditing
            ? 'Edit Resource'
            : (widget.initialUrl != null
                ? 'Save Shared Resource'
                : 'Add Free Resource')),
      ),
      body: categoriesAsync.when(
        data: (categories) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              children: [
                // Info banner when launched via Android Share-Target
                if (!widget.isEditing && widget.initialUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Material(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.share_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Shared from browser. Review details and save to your offline library.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

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

                // Category Dropdown
                DropdownButtonFormField<int?>(
                  value: _selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    prefixIcon: const Icon(Icons.category_outlined),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      tooltip: 'New Category',
                      onPressed: () => _showAddCategoryDialog(context),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Uncategorized'),
                    ),
                    ...categories.map(
                      (cat) => DropdownMenuItem<int?>(
                        value: cat.id,
                        child: Text(cat.name),
                      ),
                    ),
                  ],
                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                ),
                const SizedBox(height: 16),

                // Subcategory Field
                TextFormField(
                  controller: _subcategoryController,
                  decoration: const InputDecoration(
                    labelText: 'Subcategory / Topic',
                    hintText: 'e.g. Image Upscalers, Trackers, Streaming',
                    prefixIcon: Icon(Icons.folder_outlined),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Website Type (Free, Freemium, Open Source)
                const Text(
                  'Pricing / License Model',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: AppConstants.typeFree,
                      label: Text('Free'),
                      icon: Icon(Icons.money_off_rounded, size: 16),
                    ),
                    ButtonSegment(
                      value: AppConstants.typeFreemium,
                      label: Text('Freemium'),
                      icon: Icon(Icons.stars_outlined, size: 16),
                    ),
                    ButtonSegment(
                      value: AppConstants.typeOpenSource,
                      label: Text('Open Source'),
                      icon: Icon(Icons.code_rounded, size: 16),
                    ),
                  ],
                  selected: {_selectedWebsiteType},
                  onSelectionChanged: (selected) {
                    setState(() => _selectedWebsiteType = selected.first);
                  },
                ),
                const SizedBox(height: 16),

                // Tags Field
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (comma-separated)',
                    hintText: 'e.g. ai, free, video, productivity',
                    prefixIcon: Icon(Icons.tag_rounded),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Favicon URL Field
                TextFormField(
                  controller: _faviconController,
                  decoration: const InputDecoration(
                    labelText: 'Favicon / Icon URL (Optional)',
                    hintText: 'https://www.google.com/s2/favicons?...',
                    prefixIcon: Icon(Icons.image_outlined),
                  ),
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 28),

                // Submit Button
                FilledButton.icon(
                  onPressed: _isSaving ? null : _saveWebsite,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(widget.isEditing
                          ? Icons.save_rounded
                          : Icons.add_circle_outline),
                  label: Text(
                    _isSaving
                        ? 'Saving...'
                        : (widget.isEditing
                            ? 'Update Resource'
                            : (widget.initialUrl != null
                                ? 'Save Shared Resource'
                                : 'Add Resource')),
                  ),
                ),
                const SizedBox(height: 32),
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
