import 'package:flutter/material.dart';

class AppTheme {
  // Paleta minimalista
  static const Color primary = Color(0xFF2D6A4F);
  static const Color primaryLight = Color(0xFF52B788);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8F9FA);
  static const Color textPrimary = Color(0xFF1A1C1E);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textHint = Color(0xFFADB5BD);
  static const Color border = Color(0xFFE9ECEF);
  static const Color error = Color(0xFFDC3545);
  static const Color success = Color(0xFF2D6A4F);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: primaryLight,
        tertiary: warning,
        surface: surface,
        background: background,
        error: error,
        outline: border,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
        onError: Colors.white,
        brightness: Brightness.light,
      ),

      scaffoldBackgroundColor: background,

      // AppBar limpia y simple
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        surfaceTintColor: surface,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        toolbarHeight: 56,
        iconTheme: IconThemeData(color: textPrimary, size: 24),
        shadowColor: Colors.transparent,
      ),

      // Cards ultra-limpias
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: border, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      ),

      // Botones simples
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary.withOpacity(0.4), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Inputs limpios
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        hintStyle: TextStyle(
          color: textHint,
          fontSize: 15,
        ),
      ),

      // Bottom Navigation - limpio
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.2,
        ),
        selectedIconTheme: IconThemeData(size: 24),
        unselectedIconTheme: IconThemeData(size: 24),
      ),

      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: background,
        selectedColor: primary.withOpacity(0.12),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // Dividers
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),

      // ListTile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        subtitleTextStyle: const TextStyle(
          fontSize: 14,
          color: textSecondary,
        ),
      ),

      // Tipografía limpia
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary,
          letterSpacing: -1, height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 26, fontWeight: FontWeight.w700, color: textPrimary,
          letterSpacing: -0.8, height: 1.2,
        ),
        displaySmall: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary,
          letterSpacing: -0.5, height: 1.2,
        ),
        headlineLarge: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w600, color: textPrimary,
          letterSpacing: -0.5, height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary,
          letterSpacing: -0.3, height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary,
          letterSpacing: -0.2, height: 1.3,
        ),
        titleLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary,
          letterSpacing: -0.2, height: 1.3,
        ),
        titleMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary,
          letterSpacing: -0.1, height: 1.3,
        ),
        titleSmall: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary,
          height: 1.3,
        ),
        bodyLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary,
          letterSpacing: -0.2, height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w400, color: textPrimary,
          letterSpacing: -0.1, height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w400, color: textSecondary,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w400, color: textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w400, color: textSecondary,
        ),
      ),
    );
  }
}
