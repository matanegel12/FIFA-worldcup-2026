import 'package:flutter/material.dart';

/// All app theme configuration and color constants live here.
/// Add dark theme support here in the future.
class AppTheme {
  AppTheme._(); // prevent instantiation

  // ── Color constants ───────────────────────────────────────────────────────
  // Use these in page/widget files instead of hardcoded Color(...) literals.

  static const Color primary = Color(0xFFD32F2F);          // deep red
  static const Color secondary = Color(0xFFFFD600);        // golden yellow
  static const Color surface = Color(0xFFF2F2F7);          // light grey background
  static const Color cardColor = Colors.white;             // white cards
  static const Color lockedBannerBg = Color(0xFFFFECB3);   // light amber yellow

  /// Alias for [surface] — use when setting page background colors.
  static const Color backgroundColor = surface;

  // ── World Cup theme (main app) ────────────────────────────────────────────

  static final ThemeData light = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,       // deep red
      primary: primary,         // deep red
      secondary: secondary,     // golden yellow
      surface: surface,         // light grey
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: surface,   // light grey page background
    cardTheme: CardThemeData(
      color: cardColor,                 // white cards
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,   // white app bar
      foregroundColor: Colors.black,   // black title and icons
      elevation: 0,
      shadowColor: Colors.black12,
    ),
  );

  // ── Auth theme (sign in / sign up / auth gate) ────────────────────────────
  // Keeps the original clean Flutter blue look for auth screens
  // so they feel distinct from the main World Cup interface.

  static final ThemeData auth = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1A3A5C),   // dark navy blue
    ),
    useMaterial3: true,
  );
}
