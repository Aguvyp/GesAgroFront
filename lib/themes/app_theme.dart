import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AppTheme {
  // Colores base modernizados
  static const Color primaryGreen = Color(0xFF2E7D32); // Verde agrícola
  static const Color secondaryGreen = Color(0xFF4CAF50); // Verde claro
  static const Color accentOrange = Color(0xFFFF9800); // Naranja
  static const Color backgroundLight = Color(0xFFF5F5F5); // Fondo muy claro estilo iOS
  static const Color surfaceLight = Color(0xFFFFFFFF); // Superficie blanca
  static const Color appBarLightSurface = Color(0xFFF1F7F2); // Header suave
  static const Color bottomNavLightSurface = Color(0xFFF7FBF7); // Barra inferior diferenciada
  static const Color appBarDarkSurface = Color(0xFF121716); // Header oscuro
  static const Color bottomNavDarkSurface = Color(0xFF151B15); // Barra inferior oscura
  static const Color textPrimary = Color(0xFF1C1C1E); // Texto principal iOS
  static const Color textSecondary = Color(0xFF8E8E93); // Texto secundario iOS
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      // Color scheme moderno con verde agrícola
      colorScheme: ColorScheme.light(
        primary: primaryGreen,
        secondary: secondaryGreen,
        tertiary: accentOrange,
        surface: surfaceLight,
        surfaceVariant: appBarLightSurface,
        background: backgroundLight,
        error: const Color(0xFFFF3B30), // Rojo iOS
        outline: const Color(0xFFB7C7BB),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onSurfaceVariant: textPrimary,
        onBackground: textPrimary,
        onError: Colors.white,
        brightness: Brightness.light,
      ),
      
      // AppBar estilo iOS (más delgado y con color suave)
      appBarTheme: AppBarTheme(
        backgroundColor: appBarLightSurface,
        foregroundColor: primaryGreen,
        surfaceTintColor: appBarLightSurface,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: primaryGreen,
          letterSpacing: -0.41,
        ),
        toolbarTextStyle: const TextStyle(
          color: primaryGreen,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        toolbarHeight: 54,
        iconTheme: const IconThemeData(
          color: primaryGreen,
          size: 26,
        ),
        shadowColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
      ),
      
      // Scaffold background
      scaffoldBackgroundColor: backgroundLight,
      
      // Cards minimalistas estilo iOS
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 0.5,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // Botones estilo iOS (más planos)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.41,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: BorderSide(color: primaryGreen, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.41,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.41,
          ),
        ),
      ),
      
      // Inputs estilo Cupertino
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF3B30)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF3B30), width: 2),
        ),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 17,
          fontWeight: FontWeight.w400,
        ),
        hintStyle: TextStyle(
          color: textSecondary.withOpacity(0.6),
          fontSize: 17,
        ),
      ),
      
      // Bottom Navigation Bar estilo iOS con superficie diferenciada
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: bottomNavLightSurface,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.24,
          color: primaryGreen,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.24,
          color: textSecondary,
        ),
        selectedIconTheme: const IconThemeData(
          size: 28,
        ),
        unselectedIconTheme: const IconThemeData(
          size: 26,
        ),
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Chips estilo iOS
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.withOpacity(0.1),
        selectedColor: primaryGreen.withOpacity(0.2),
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      
      // Dividers sutiles
      dividerTheme: DividerThemeData(
        color: Colors.grey.withOpacity(0.2),
        thickness: 0.5,
        space: 1,
      ),
      
      // ListTile estilo iOS
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 15,
          color: textSecondary,
        ),
      ),
      
      // Tipografía estilo iOS (SF Pro)
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: 0.37,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: 0.36,
          height: 1.2,
        ),
        displaySmall: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: 0.35,
          height: 1.2,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.35,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.38,
          height: 1.2,
        ),
        headlineSmall: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.41,
          height: 1.2,
        ),
        titleLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.41,
          height: 1.2,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.24,
          height: 1.2,
        ),
        titleSmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.08,
          height: 1.2,
        ),
        bodyLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          letterSpacing: -0.41,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          letterSpacing: -0.24,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          letterSpacing: -0.08,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          letterSpacing: -0.41,
        ),
        labelMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          letterSpacing: -0.24,
        ),
        labelSmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          letterSpacing: -0.08,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    const Color darkBackground = Color(0xFF000000);
    const Color darkSurface = Color(0xFF1C1C1E);
    const Color darkTextPrimary = Color(0xFFFFFFFF);
    const Color darkTextSecondary = Color(0xFF8E8E93);
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: primaryGreen,
        secondary: secondaryGreen,
        tertiary: accentOrange,
        surface: darkSurface,
        surfaceVariant: appBarDarkSurface,
        background: darkBackground,
        error: const Color(0xFFFF453A),
        outline: const Color(0xFF2E7D32),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkTextPrimary,
        onSurfaceVariant: darkTextPrimary,
        onBackground: darkTextPrimary,
        onError: Colors.white,
        brightness: Brightness.dark,
      ),
      
      appBarTheme: AppBarTheme(
        backgroundColor: appBarDarkSurface,
        foregroundColor: primaryGreen,
        surfaceTintColor: appBarDarkSurface,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: primaryGreen,
          letterSpacing: -0.41,
        ),
        toolbarTextStyle: const TextStyle(
          color: primaryGreen,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        toolbarHeight: 54,
        iconTheme: const IconThemeData(
          color: primaryGreen,
          size: 26,
        ),
        shadowColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
      ),
      
      scaffoldBackgroundColor: darkBackground,
      
      cardTheme: CardThemeData(
        elevation: 0,
        color: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 0.5,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: bottomNavDarkSurface,
        selectedItemColor: primaryGreen,
        unselectedItemColor: darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.24,
          color: primaryGreen,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.24,
          color: darkTextSecondary,
        ),
        selectedIconTheme: const IconThemeData(
          size: 28,
        ),
        unselectedIconTheme: const IconThemeData(
          size: 26,
        ),
      ),
      
      // Replicar otros temas para dark mode
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
      ),
    );
  }
}
