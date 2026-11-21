import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Brand Colors - Modern Gradient-Based Palette (from skills design principles)
  static const Color primaryColor = Color(0xFF6750A4); // Deep purple (Material 3 Tonal)
  static const Color primaryContainer = Color(0xFFEADDFF);
  static const Color primaryOnContainer = Color(0xFF21005D);

  static const Color secondaryColor = Color(0xFF7C6DFF); // Violet
  static const Color secondaryContainer = Color(0xFFFFD8FF);
  static const Color secondaryOnContainer = Color(0xFF381E72);

  static const Color tertiaryColor = Color(0xFFA58EFF); // Lavender
  static const Color tertiaryContainer = Color(0xFFFEE7FF);
  static const Color tertiaryOnContainer = Color(0xFF4F378B);

  // Accent Colors for different types
  static const Color successColor = Color(0xFF4CAF50);
  static const Color successContainer = Color(0xFFE8F5E9);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color warningContainer = Color(0xFFFFF8E1);
  static const Color errorColor = Color(0xFFB00020);
  static const Color errorContainer = Color(0xFFFCD8D6);

  // Dark Theme Colors with proper Material 3 guidance
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1C1B1F);
  static const Color darkSurfaceVariant = Color(0xFF49454F);
  static const Color darkCardColor = Color(0xFF262626);
  static const Color darkBorderColor = Color(0xFF625B64);
  static const Color darkTextPrimary = Color(0xFFE8E8E8);
  static const Color darkTextSecondary = Color(0xFFB7B7B7);
  static const Color darkTextTertiary = Color(0xFF8A8A8A);

  // Light Theme Colors with proper contrast
  static const Color lightBackground = Color(0xFFF8F8F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardColor = Color(0xFFFFFFFF);
  static const Color lightBorderColor = Color(0xFFE0E0E0);
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF5A5A5A);
  static const Color lightTextTertiary = Color(0xFF7A7A7A);

  // AMOLED Colors
  static const Color amoledBackground = Color(0xFF000000);
  static const Color amoledSurface = Color(0xFF0A0A0A);
  static const Color amoledCardColor = Color(0xFF111118);

  // Modern gradient definitions
  static const List<Color> primaryGradient = [
    Color(0xFF6750A4),
    Color(0xFF9371B5),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF7C6DFF),
    Color(0xFFA5C3FF),
  ];

  static const List<Color> successGradient = [
    Color(0xFF4CAF50),
    Color(0xFF8BCB8A),
  ];

  // Category Colors - Vibrant but harmonious
  static const List<Color> categoryColors = [
    Color(0xFF6750A4), // Purple
    Color(0xFF7C6DFF), // Violet
    Color(0xFF65C1FF), // Light Blue
    Color(0xFF00B3E6), // Cyan
    Color(0xFF00B38C), // Teal
    Color(0xFF00C853), // Green
    Color(0xFF69C0FF), // Sky Blue
    Color(0xFF56ACE4), // Azure
    Color(0xFF68D391), // Mint
    Color(0xFF76BF9F), // Sea Green
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
        surfaceVariant: isDark ? darkSurfaceVariant : Colors.grey[300]!
            .withValues(alpha: 0.3),
        onSurfaceVariant: isDark ? darkTextSecondary : lightTextTertiary,
        outline: outline,
        outlineVariant: isDark ? darkBorderColor.withValues(alpha: 0.5) : lightBorderColor.withValues(alpha: 0.5),
        inverseSurface: isDark ? darkCardColor : lightCardColor,
        onInverseSurface: isDark ? darkTextSecondary : lightTextPrimary,
        surfaceContainerLowest: isDark ? darkBackground : lightBackground,
        surfaceContainerLow: isDark ? darkSurface : lightSurface,
        surfaceContainer: card,
        surfaceContainerHigh: isDark ? darkCardColor : lightCardColor.withValues(alpha: 0.9),
        surfaceContainerHighest: card,
      ),
      scaffoldBackgroundColor: isAmoled ? Colors.black : (isDark ? darkBackground : lightBackground),
      cardTheme: CardTheme(
        color: card,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: outline.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isAmoled ? Colors.black : (isDark ? darkBackground : lightBackground),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: onSurface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        elevation: 0,
        indicatorColor: primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: primary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
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
          return IconThemeData(color: onSurface.withValues(alpha: 0.7), size: 24);
        }),
        height: 64,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outline.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outline.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: errorColor),
        ),
        labelStyle: TextStyle(color: onSurface.withValues(alpha: 0.7)),
        hintStyle: TextStyle(color: onSurface.withValues(alpha: 0.5)),
        prefixIconColor: onSurface.withValues(alpha: 0.6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: card,
        selectedColor: primary.withValues(alpha: 0.25),
        labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: onSurface),
        secondaryLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: outline.withValues(alpha: 0.5)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: outline.withValues(alpha: 0.5),
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: card,
        contentTextStyle: TextStyle(color: onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
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
        elevation: 6,
        shape: const CircleBorder(),
      ),
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          color: onSurface,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        headlineLarge: TextStyle(
          color: onSurface,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        headlineMedium: TextStyle(
          color: onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        headlineSmall: TextStyle(
          color: onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w500,
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
        ),
        bodyMedium: TextStyle(
          color: onSurface.withValues(alpha: 0.75),
          fontSize: 14,
          fontWeight: FontWeight.w400,
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
