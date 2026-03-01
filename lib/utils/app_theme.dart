import 'package:flutter/material.dart';

/// App-wide color palette and theme configuration.
class AppTheme {
  // ─── Brand Colors ─────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1E6B4A);      // Deep green
  static const Color primaryLight = Color(0xFF2E9B6E);
  static const Color primaryDark = Color(0xFF144D35);
  static const Color accent = Color(0xFFFF6B35);        // Warm orange
  static const Color accentLight = Color(0xFFFF8C5A);

  // ─── Status Colors ────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF2980B9);

  // ─── Neutrals ─────────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C9A);
  static const Color divider = Color(0xFFECF0F1);
  static const Color cardShadow = Color(0x1A000000);

  // ─── Module Colors ────────────────────────────────────────────────────────────
  static const Color clientColor = Color(0xFF3498DB);
  static const Color orderColor = Color(0xFF9B59B6);
  static const Color purchaseColor = Color(0xFFE67E22);
  static const Color employeeColor = Color(0xFF1ABC9C);
  static const Color inventoryColor = Color(0xFFE74C3C);
  static const Color reportColor = Color(0xFF2C3E50);

  // ─── Light Theme ─────────────────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 2,
          shadowColor: cardShadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFDDE3EA)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFDDE3EA)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: error),
          ),
          labelStyle: const TextStyle(color: textSecondary),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: primary.withOpacity(0.1),
          selectedColor: primary,
          labelStyle: const TextStyle(fontSize: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: accent,
          foregroundColor: Colors.white,
        ),
        dividerTheme: const DividerThemeData(
          color: divider,
          thickness: 1,
        ),
      );

  // ─── Dark Theme ──────────────────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1E1E),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryLight,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
}
