// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

/// Provider pour gérer le thème clair/sombre basé sur deux palettes définies.
class ThemeProvider with ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;
  ThemeMode get themeMode => _mode;

  // Palette claire
  static const Color _deepGreen = Color(0xFF18534F);
  static const Color _teal = Color(0xFF226D68);
  static const Color _mint = Color(0xFFECF8F6);
  static const Color _amber = Color(0xFFFEEAA1);
  static const Color _copper = Color(0xFFD6955B);

  // Palette sombre
  static const Color _charcoal1 = Color(0xFF242423);
  static const Color _charcoal2 = Color(0xFF333533);
  static const Color _sun = Color(0xFFF5CB5C);
  static const Color _offWhite = Color(0xFFE8EDDF);
  static const Color _grey = Color(0xFFCFDBD5);

  ThemeData get lightTheme {
    final scheme = ColorScheme.light(
      primary: _teal,
      onPrimary: Colors.white,
      secondary: _copper,
      onSecondary: Colors.white,
      background: _mint,
      onBackground: _deepGreen,
      surface: Colors.white,
      onSurface: _deepGreen,
      tertiary: _amber,
      
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _mint,
      appBarTheme: AppBarTheme(
        backgroundColor: _mint,
        foregroundColor: _deepGreen,
        elevation: 0,
      ),
    );
  }

  ThemeData get darkTheme {
    final scheme = ColorScheme.dark(
      primary: _offWhite,
      onPrimary: _charcoal1,
      secondary: _grey,
      onSecondary: _charcoal1,
      background: _charcoal1,
      onBackground: _offWhite,
      surface: _charcoal2,
      onSurface: _offWhite,
      tertiary: _sun,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _charcoal1,
      appBarTheme: AppBarTheme(
        backgroundColor: _charcoal1,
        foregroundColor: _offWhite,
        elevation: 0,
      ),
    );
  }

  void toggleTheme() {
    _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _mode = mode;
    notifyListeners();
  }
}
