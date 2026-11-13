import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'presentation/navigation/app_router.dart';
import 'presentation/providers/theme_provider.dart';

class FreeHubApp extends ConsumerWidget {
  const FreeHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
