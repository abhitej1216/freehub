import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Brand Colors - High-Craft Linear/Vercel Inspired Palette
  static const Color primaryColor = Color(0xFF6366F1); // Electric Indigo
  static const Color primaryContainer = Color(0xFF312E81);
  static const Color primaryOnContainer = Color(0xFFEEF2FF);

  static const Color secondaryColor = Color(0xFF8B5CF6); // Radiant Violet
  static const Color secondaryContainer = Color(0xFF4C1D95);
  static const Color secondaryOnContainer = Color(0xFFF5F3FF);

  static const Color tertiaryColor = Color(0xFF06B6D4); // Cyber Cyan
  static const Color tertiaryContainer = Color(0xFF164E63);
  static const Color tertiaryOnContainer = Color(0xFFECFEFF);

  // Accent Colors for different resource models
  static const Color successColor = Color(0xFF10B981); // Emerald (Free)
  static const Color successContainer = Color(0xFF064E3B);
  static const Color warningColor = Color(0xFFF59E0B); // Amber (Freemium)
  static const Color warningContainer = Color(0xFF78350F);
  static const Color errorColor = Color(0xFFEF4444); // Crimson
  static const Color errorContainer = Color(0xFF7F1D1D);

  // Dark Theme Colors - Deep Obsidian with Layered Contrast
  static const Color darkBackground = Color(0xFF090A0E);
  static const Color darkSurface = Color(0xFF111319);
  static const Color darkCardColor = Color(0xFF161922);
  static const Color darkBorderColor = Color(0xFF232734);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextTertiary = Color(0xFF64748B);

  // Light Theme Colors - Crisp Minimalist
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardColor = Color(0xFFFFFFFF);
  static const Color lightBorderColor = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextTertiary = Color(0xFF94A3B8);

  // AMOLED Colors - Pure OLED Black
  static const Color amoledBackground = Color(0xFF000000);
  static const Color amoledSurface = Color(0xFF0A0B0E);
  static const Color amoledCardColor = Color(0xFF101217);

  // Modern gradient definitions
  static const List<Color> primaryGradient = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
  ];

  static const List<Color> successGradient = [
    Color(0xFF10B981),
    Color(0xFF34D399),
  ];

  // Category Colors - Curated Vibrant & Harmonious
  static const List<Color> categoryColors = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Violet
    Color(0xFFEC4899), // Pink
    Color(0xFF06B6D4), // Cyan
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFF3B82F6), // Blue
    Color(0xFF14B8A6), // Teal
    Color(0xFF84CC16), // Lime
    Color(0xFFA855F7), // Purple
  ];

  static ThemeData get darkTheme => _buildTheme(
        brightness: Brightness.dark,
        primary: primaryColor,
        primaryContainer: darkCardColor,
        surface: darkSurface,
        onSurface: darkTextPrimary,
        outline: darkBorderColor,
        card: darkCardColor,
      );

  static ThemeData get amoledTheme => _buildTheme(
        brightness: Brightness.dark,
        primary: primaryColor,
        primaryContainer: amoledCardColor,
        surface: amoledSurface,
        onSurface: darkTextPrimary,
        outline: darkBorderColor,
        card: amoledCardColor,
        isAmoled: true,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
    required Color primaryContainer,
    required Color surface,
    required Color onSurface,
    required Color outline,
    required Color card,
    bool isAmoled = false,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: ZoomPageTransitionsBuilder(),
        },
      ),
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: primaryContainer,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        secondaryContainer: secondaryContainer,
        tertiary: tertiaryColor,
        onTertiary: Colors.white,
        tertiaryContainer: tertiaryContainer,
        error: errorColor,
        onError: Colors.white,
        errorContainer: errorContainer,
        surface: surface,
        onSurface: onSurface,
        onSurfaceVariant: isDark ? darkTextSecondary : lightTextTertiary,
        outline: outline,
        outlineVariant: isDark
            ? darkBorderColor.withValues(alpha: 0.6)
            : lightBorderColor.withValues(alpha: 0.6),
        inverseSurface: isDark ? darkCardColor : lightCardColor,
        onInverseSurface: isDark ? darkTextSecondary : lightTextPrimary,
        surfaceContainerLowest: isDark ? darkBackground : lightBackground,
        surfaceContainerLow: isDark ? darkSurface : lightSurface,
        surfaceContainer: card,
        surfaceContainerHigh:
            isDark ? darkCardColor : lightCardColor.withValues(alpha: 0.9),
        surfaceContainerHighest: card,
      ),
      scaffoldBackgroundColor:
          isAmoled ? Colors.black : (isDark ? darkBackground : lightBackground),
      cardTheme: CardTheme(
        color: card,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: outline.withValues(alpha: isDark ? 0.45 : 0.6),
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isAmoled
            ? Colors.black
            : (isDark ? darkBackground : lightBackground),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        iconTheme: IconThemeData(color: onSurface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        elevation: 0,
        indicatorColor: primary.withValues(alpha: 0.16),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: primary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            );
          }
          return TextStyle(
            color: onSurface.withValues(alpha: 0.6),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primary, size: 24);
          }
          return IconThemeData(
              color: onSurface.withValues(alpha: 0.7), size: 24);
        }),
        height: 64,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: outline.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: outline.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: errorColor),
        ),
        labelStyle: TextStyle(color: onSurface.withValues(alpha: 0.7)),
        hintStyle: TextStyle(color: onSurface.withValues(alpha: 0.45)),
        prefixIconColor: onSurface.withValues(alpha: 0.6),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: card,
        selectedColor: primary.withValues(alpha: 0.18),
        labelStyle:
            TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: onSurface),
        secondaryLabelStyle:
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: outline.withValues(alpha: 0.5)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: outline.withValues(alpha: 0.4),
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? const Color(0xFF1E222D) : Colors.white,
        contentTextStyle: TextStyle(
          color: onSurface,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: outline.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        elevation: 16,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        insetPadding: const EdgeInsets.all(24),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minVerticalPadding: 12,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: onSurface.withValues(alpha: 0.7),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: onSurface,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
        ),
        displayMedium: TextStyle(
          color: onSurface,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        headlineLarge: TextStyle(
          color: onSurface,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        headlineMedium: TextStyle(
          color: onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        headlineSmall: TextStyle(
          color: onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        titleLarge: TextStyle(
          color: onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          color: onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
        titleSmall: TextStyle(
          color: onSurface.withValues(alpha: 0.85),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: onSurface.withValues(alpha: 0.75),
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.45,
        ),
        bodySmall: TextStyle(
          color: onSurface.withValues(alpha: 0.6),
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          color: onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(
          color: onSurface.withValues(alpha: 0.85),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: onSurface.withValues(alpha: 0.7),
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return _buildTheme(
      brightness: Brightness.light,
      primary: primaryColor,
      primaryContainer: primaryContainer,
      surface: lightSurface,
      onSurface: lightTextPrimary,
      outline: lightBorderColor,
      card: lightCardColor,
    );
  }
}
