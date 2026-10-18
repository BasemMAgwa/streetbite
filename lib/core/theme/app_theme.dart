import 'package:flutter/material.dart';

class AppTheme {
  static const green = Color(0xFF00C874);
  static const badgeGreen = Color(0xFF007D49);
  static const paleMint = Color(0xFFE5F8F1);
  static const ink = Color(0xFF202124);
  static const muted = Color(0xFF858B94);
  static const darkBackground = Color(0xFF121C19);
  static const darkCard = Color(0xFF263A33);
  static const darkCardBorder = Color(0xFF3F5A4E);
  static const sectionFont = 'sf-pro';
  static const bodyFont = 'sf-compact';

  static ThemeData get light => _build(Brightness.light);

  static Color cardColor(ThemeData theme) => theme.brightness == Brightness.dark
      ? darkCard
      : theme.colorScheme.surfaceContainerLow;

  static BorderSide cardBorder(ThemeData theme) =>
      theme.brightness == Brightness.dark
      ? const BorderSide(color: darkCardBorder)
      : BorderSide.none;

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final background = isDark ? darkBackground : Colors.white;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: bodyFont,
      colorScheme: ColorScheme.fromSeed(
        seedColor: green,
        brightness: brightness,
      ),
      scaffoldBackgroundColor: background,
      canvasColor: isDark ? darkCard : Colors.white,
      cardColor: isDark ? darkCard : Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: isDark ? Colors.white : ink,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? darkCard : paleMint,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFF007D49), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
