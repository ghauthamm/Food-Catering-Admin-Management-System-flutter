import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// App-wide color palette and theme configuration.
class AppTheme {
  // ─── Brand Colors ─────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1A7A52);      // Rich forest green
  static const Color primaryLight = Color(0xFF28A96E);
  static const Color primaryDark = Color(0xFF0F4F33);
  static const Color accent = Color(0xFFFF6B35);        // Warm orange
  static const Color accentLight = Color(0xFFFF9A6C);
  static const Color accentDark = Color(0xFFE04D1A);

  // ─── Status Colors ────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ─── Neutrals ─────────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF8F3EE);   // Warm cream
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1C2B20);
  static const Color textSecondary = Color(0xFF6B7B70);
  static const Color divider = Color(0xFFE8EDE9);
  static const Color cardShadow = Color(0x14000000);

  // ─── Module Colors ────────────────────────────────────────────────────────────
  static const Color clientColor   = Color(0xFF3B82F6); // Blue
  static const Color orderColor    = Color(0xFF8B5CF6); // Purple
  static const Color purchaseColor = Color(0xFFF97316); // Orange
  static const Color employeeColor = Color(0xFF14B8A6); // Teal
  static const Color inventoryColor= Color(0xFFEF4444); // Red
  static const Color reportColor   = Color(0xFF6366F1); // Indigo

  // ─── Gradient Presets ────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0F4F33), Color(0xFF1A7A52), Color(0xFF28A96E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFE04D1A), Color(0xFFFF6B35), Color(0xFFFF9A6C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dashboardHeaderGradient = LinearGradient(
    colors: [Color(0xFF0F4F33), Color(0xFF1A7A52)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient warmBgGradient = LinearGradient(
    colors: [Color(0xFFF8F3EE), Color(0xFFEFF6EF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient moduleGradient(Color color) => LinearGradient(
    colors: [color.withValues(alpha: 0.9), color],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Sets the status bar to transparent (call from initState).
  static void setSystemUiOverlay({bool dark = false}) {
    SystemChrome.setSystemUIOverlayStyle(
      dark
          ? SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent),
    );
  }

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
