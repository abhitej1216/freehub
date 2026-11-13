import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import 'database_providers.dart';

enum AppThemeMode {
  system,
  light,
  dark,
  amoled,
}

class ThemeNotifier extends StateNotifier<AppThemeMode> {
  final Ref _ref;

  ThemeNotifier(this._ref) : super(AppThemeMode.dark) {
    _loadTheme();
  }

  void _loadTheme() {
    try {
      final prefs = _ref.read(sharedPreferencesProvider);
      final savedTheme = prefs.getString(AppConstants.prefThemeMode);
      if (savedTheme != null) {
        state = AppThemeMode.values.firstWhere(
          (e) => e.name == savedTheme,
          orElse: () => AppThemeMode.dark,
        );
      }
    } catch (_) {
      state = AppThemeMode.dark;
    }
  }

  Future<void> setTheme(AppThemeMode mode) async {
    state = mode;
    try {
      final prefs = _ref.read(sharedPreferencesProvider);
      await prefs.setString(AppConstants.prefThemeMode, mode.name);
    } catch (_) {}
  }

  ThemeMode get flutterThemeMode {
    switch (state) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
      case AppThemeMode.amoled:
        return ThemeMode.dark;
    }
  }

  bool get isAmoled => state == AppThemeMode.amoled;
}

final themeProvider =
    StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier(ref);
});
