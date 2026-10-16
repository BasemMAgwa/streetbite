import 'package:flutter/material.dart';

class AppTheme {
  static const green = Color(0xFF00C874);
  static const paleMint = Color(0xFFE5F8F1);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'sf-pro',
    colorScheme: ColorScheme.fromSeed(seedColor: green),
    scaffoldBackgroundColor: green,
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: paleMint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFF007D49), width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}
