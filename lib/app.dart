import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'presentation/navigation/app_router.dart';
import 'presentation/providers/database_providers.dart';
import 'presentation/providers/theme_provider.dart';

class FreeHubApp extends ConsumerStatefulWidget {
  const FreeHubApp({super.key});

  @override
  ConsumerState<FreeHubApp> createState() => _FreeHubAppState();
}

class _FreeHubAppState extends ConsumerState<FreeHubApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initShareIntent();
    });
  }

  void _initShareIntent() {
    try {
      final shareService = ref.read(shareIntentServiceProvider);
      shareService.initSharingListener(
        onDataReceived: (data) {
          if (!mounted) return;
          debugPrint(
              'Received shared resource: ${data.url} (${data.suggestedTitle})');
          appRouter.push(
            '/add-website',
            extra: {
              'url': data.url,
              'name': data.suggestedTitle,
            },
          );
        },
      );
    } catch (e) {
      debugPrint('Share-Target init notice: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch theme provider to rebuild when theme changes
    ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    // Pick dark theme (AMOLED or Standard Dark)
    final darkTheme = themeNotifier.isAmoled
        ? AppTheme.amoledTheme
        : AppTheme.darkTheme;

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: AppTheme.lightTheme,
      darkTheme: darkTheme,
      themeMode: themeNotifier.flutterThemeMode,
    );
  }
}
