import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freehub/core/constants/app_constants.dart';
import 'package:freehub/presentation/providers/theme_provider.dart';
import 'package:freehub/presentation/providers/website_providers.dart';
import 'package:freehub/presentation/widgets/section_header.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentTheme = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Section: Appearance / Theme
          const SizedBox(height: 8),
          SectionHeader(
            title: 'Appearance',
            icon: Icons.palette_outlined,
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildThemeOption(
                  context: context,
                  title: 'Dark Theme',
                  subtitle: 'Deep charcoal modern dark interface',
                  icon: Icons.dark_mode_outlined,
                  selected: currentTheme == AppThemeMode.dark,
                  onChanged: () => themeNotifier.setTheme(AppThemeMode.dark),
                ),
                const Divider(height: 1),
                _buildThemeOption(
                  context: context,
                  title: 'AMOLED Black Theme',
                  subtitle: 'Pure black background for OLED screens',
                  icon: Icons.brightness_2_outlined,
                  selected: currentTheme == AppThemeMode.amoled,
                  onChanged: () => themeNotifier.setTheme(AppThemeMode.amoled),
                ),
                const Divider(height: 1),
                _buildThemeOption(
                  context: context,
                  title: 'Light Theme',
                  subtitle: 'Crisp and bright interface',
                  icon: Icons.light_mode_outlined,
                  selected: currentTheme == AppThemeMode.light,
                  onChanged: () => themeNotifier.setTheme(AppThemeMode.light),
                ),
                const Divider(height: 1),
                _buildThemeOption(
                  context: context,
                  title: 'System Default',
                  subtitle: 'Follows system dark/light preference',
                  icon: Icons.settings_system_daydream_outlined,
                  selected: currentTheme == AppThemeMode.system,
                  onChanged: () => themeNotifier.setTheme(AppThemeMode.system),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section: Data & Backup
          const SizedBox(height: 4),
          SectionHeader(
            title: 'Data & Backup',
            icon: Icons.backup_outlined,
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildMenuOption(
                  context: context,
                  icon: Icons.cloud_sync_outlined,
                  title: 'Sync with FMHY Online',
                  subtitle: 'Fetch latest resources directly from FMHY GitHub repo',
                  onTap: () => _handleOnlineSync(context, ref),
                ),
                const Divider(height: 1),
                _buildMenuOption(
                  context: context,
                  icon: Icons.sync_rounded,
                  title: 'Restore FMHY Resources',
                  subtitle: 'Re-import the 449 curated offline FMHY directory resources',
                  onTap: () => _handleRestoreBundled(context, ref),
                ),
                const Divider(height: 1),
                _buildMenuOption(
                  context: context,
                  icon: Icons.file_upload_outlined,
                  title: 'Export JSON Backup',
                  subtitle: 'Save your categories and websites to a file',
                  onTap: () => _handleExport(context, ref),
                ),
                const Divider(height: 1),
                _buildMenuOption(
                  context: context,
                  icon: Icons.file_download_outlined,
                  title: 'Import JSON Backup',
                  subtitle: 'Restore from backup or external directory file',
                  onTap: () => _handleImport(context, ref),
                ),
                const Divider(height: 1),
                _buildDestructiveMenuOption(
                  context: context,
                  icon: Icons.delete_sweep_outlined,
                  title: 'Clear Browsing History',
                  subtitle: 'Reset recently visited sites tracker',
                  onTap: () => _handleClearHistory(context, ref),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section: Database Info
          const SizedBox(height: 4),
          SectionHeader(
            title: 'Database Information',
            icon: Icons.database_outlined,
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: statsAsync.when(
                data: (stats) => Column(
                  children: [
                    _buildInfoRow('Database Engine', 'SQLite (sqflite)'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Schema Version', 'v${AppConstants.dbVersion}'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Total Websites', '${stats.totalWebsites}'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Total Categories', '${stats.totalCategories}'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Bookmarks', '${stats.totalBookmarks}'),
                    const SizedBox(height: 8),
                    _buildInfoRow('History Visits', '${stats.totalVisits}'),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Error loading stats: $err'),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Section: About
          const SizedBox(height: 4),
          const SectionHeader(
            title: 'About',
            icon: Icons.info_outlined,
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Column(
              children: [
                _buildAboutOption(
                  context: context,
                  icon: Icons.info_outline_rounded,
                  title: AppConstants.appName,
                  subtitle: AppConstants.appDescription,
                ),
                const Divider(height: 1),
                _buildAboutOption(
                  context: context,
                  icon: Icons.verified_outlined,
                  title: 'Version',
                  subtitle: AppConstants.appVersion,
                ),
                const Divider(height: 1),
                _buildAboutOption(
                  context: context,
                  icon: Icons.wifi_off_outlined,
                  title: '100% Offline Capable',
                  subtitle: 'All resources stored locally in SQLite. Works completely without internet connection.',
                ),
                const Divider(height: 1),
                _buildAboutOption(
                  context: context,
                  icon: Icons.code_outlined,
                  title: 'Source Code',
                  subtitle: 'View and contribute to the project',
                  onTap: () {
                    // Open GitHub repo
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: selected
                ? [
                    colorScheme.primary.withValues(alpha: 0.3),
                    colorScheme.primary.withValues(alpha: 0.15),
                  ]
                : [
                    colorScheme.surfaceContainerLow,
                    colorScheme.surfaceContainerLow.withValues(alpha: 0.7),
                  ],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 22,
          color: selected ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? colorScheme.primary : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: selected
          ? Icon(
              Icons.check_rounded,
              color: colorScheme.primary,
              size: 20,
            )
          : null,
      onTap: onChanged,
    );
  }

  Widget _buildMenuOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, size: 24, color: colorScheme.primary),
      title: Text(title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          )),
      subtitle: Text(subtitle,
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          )),
      trailing: Icon(Icons.chevron_right, color: colorScheme.onSurface.withValues(alpha: 0.5)),
      onTap: onTap,
    );
  }

  Widget _buildDestructiveMenuOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Icon(icon, size: 24, color: colorScheme.error),
      title: Text(title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: colorScheme.error,
          )),
      subtitle: Text(subtitle,
          style: TextStyle(
            color: colorScheme.error.withValues(alpha: 0.85),
          )),
      trailing: Icon(Icons.chevron_right, color: colorScheme.error),
      onTap: onTap,
    );
  }

  Widget _buildAboutOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          )),
      subtitle: Text(subtitle,
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          )),
      trailing: onTap != null ? Icon(Icons.chevron_right,
          color: colorScheme.onSurface.withValues(alpha: 0.5)) : null,
      onTap: onTap,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            )),
        Text(value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            )),
      ],
    );
  }

  Future<void> _handleOnlineSync(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    bool updateExisting = false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.cloud_sync_outlined),
                  SizedBox(width: 8),
                  Text('Sync with FMHY Online'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fetch real-time updates directly from the official FMHY GitHub repository (15 categories).\n\nYour custom websites and bookmarks will NEVER be overwritten.',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Duplicate Handling:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  RadioListTile<bool>(
                    title: const Text('Skip duplicates'),
                    subtitle: const Text('Keep existing descriptions intact'),
                    value: false,
                    groupValue: updateExisting,
                    onChanged: (val) {
                      setDialogState(() => updateExisting = val ?? false);
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<bool>(
                    title: const Text('Update duplicates'),
                    subtitle: const Text('Refresh descriptions with latest GitHub info'),
                    value: true,
                    groupValue: updateExisting,
                    onChanged: (val) {
                      setDialogState(() => updateExisting = val ?? true);
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.cloud_download_outlined),
                  label: const Text('Sync Now'),
                  onPressed: () => Navigator.pop(ctx, true),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    final progressNotifier = ValueNotifier<double>(0.0);
    final statusNotifier = ValueNotifier<String>('Connecting to FMHY GitHub...');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text('Syncing FMHY Resources'),
            content: ValueListenableBuilder<double>(
              valueListenable: progressNotifier,
              builder: (ctx, progress, _) {
                return ValueListenableBuilder<String>(
                  valueListenable: statusNotifier,
                  builder: (ctx, status, _) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(status, style: const TextStyle(fontSize: 13)),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: progress > 0 ? progress : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          progress > 0
                              ? '${(progress * 100).toInt()}% completed'
                              : 'Starting...',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );

    try {
      final syncService = ref.read(fmhySyncServiceProvider);
      final result = await syncService.syncFromGithub(
        onProgress: (status, progress) {
          statusNotifier.value = status;
          progressNotifier.value = progress;
        },
        updateExisting: updateExisting,
      );

      // Close progress dialog
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      ref.read(websiteControllerProvider).refreshAll();

      if (context.mounted) {
        if (result.success) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                'Sync complete! ${result.newAdded} new resources added, ${result.updated} updated, ${result.skipped} unchanged.',
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Sync Notice'),
              content: Text(result.message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Sync error: $e'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    } finally {
      progressNotifier.dispose();
      statusNotifier.dispose();
    }
  }

  Future<void> _handleExport(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      messenger.showSnackBar(
        const SnackBar(content: Text('Generating directory backup...')),
      );
      final service = ref.read(importExportServiceProvider);
      await service.shareBackup();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  Future<void> _handleImport(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Selected file is empty or unreadable.')),
        );
        return;
      }

      final jsonContent = utf8.decode(bytes);
      final service = ref.read(importExportServiceProvider);
      final preview = await service.previewJsonString(jsonContent);

      if (!context.mounted) return;

      if (!preview.isValid) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Invalid Backup File'),
            content: Text(preview.errorMessage ?? 'Unrecognized format.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      // Show preview dialog
      bool updateExisting = false;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              return AlertDialog(
                title: const Text('Import Directory Data'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Websites in file: ${preview.totalWebsitesInFile}'),
                    const SizedBox(height: 4),
                    Text('Categories in file: ${preview.totalCategoriesInFile}'),
                    const SizedBox(height: 4),
                    Text('New websites to add: ${preview.newWebsitesCount}'),
                    const SizedBox(height: 4),
                    Text('Existing duplicate URLs: ${preview.duplicateUrlsCount}'),
                    const Divider(height: 24),
                    const Text(
                      'Duplicate Handling:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    RadioListTile<bool>(
                      title: const Text('Skip duplicates'),
                      subtitle: const Text('Keep existing entries intact'),
                      value: false,
                      groupValue: updateExisting,
                      onChanged: (val) {
                        setDialogState(() => updateExisting = val ?? false);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    RadioListTile<bool>(
                      title: const Text('Update duplicates'),
                      subtitle: const Text('Overwrite existing with new info'),
                      value: true,
                      groupValue: updateExisting,
                      onChanged: (val) {
                        setDialogState(() => updateExisting = val ?? true);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Import'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (confirmed == true && context.mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Importing resources...')),
        );
        final importResult = await service.executeImport(
          preview,
          updateExisting: updateExisting,
        );
        ref.read(websiteControllerProvider).refreshAll();
        if (context.mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(importResult.message ?? 'Import complete!'),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Import error: $e')),
      );
    }
  }

  Future<void> _handleRestoreBundled(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore FMHY Resources?'),
        content: const Text(
          'This will import all 449 curated internet resources from the bundled FMHY catalog. Your custom-created resources and bookmarks will NOT be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        messenger.showSnackBar(
          const SnackBar(content: Text('Restoring bundled FMHY catalog...')),
        );
        final service = ref.read(importExportServiceProvider);
        final jsonString =
            await rootBundle.loadString(AppConstants.initialDataAsset);
        final preview = await service.previewJsonString(jsonString);
        final result = await service.executeImport(
          preview,
          updateExisting: true,
          keepCustomWebsites: true,
        );
        ref.read(websiteControllerProvider).refreshAll();
        if (context.mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                'FMHY catalog restored! ${result.importedCount} added, ${result.updatedCount} refreshed.',
              ),
            ),
          );
        }
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text('Restore error: $e')),
        );
      }
    }
  }

  Future<void> _handleClearHistory(BuildContext context, WidgetRef ref) async {
    final theme = Theme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Visit History?'),
        content: const Text(
            'This will erase all recorded website visits. Your saved websites and bookmarks will not be affected.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final dbHelper = ref.read(databaseHelperProvider);
      await dbHelper.clearVisitHistory();
      ref.read(websiteControllerProvider).refreshAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Visit history cleared')),
        );
      }
    }
  }
}