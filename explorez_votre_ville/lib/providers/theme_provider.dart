// lib/providers/theme_provider.dart
//
// Gère le thème clair/sombre à partir de deux palettes définies.
// Expose :
// - themeMode (clair/sombre)
// - lightTheme / darkTheme (ColorScheme + quelques réglages AppBar/scaffold)
// - toggleTheme() et setThemeMode()

import 'package:flutter/material.dart';

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

  /// Thème clair (ColorScheme + AppBar/scaffold)
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
      appBarTheme: const AppBarTheme(
        elevation: 0,
      ),
    );
  }

  /// Thème sombre (ColorScheme + AppBar/scaffold)
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
      appBarTheme: const AppBarTheme(
        elevation: 0,
      ),
    );
  }

  /// Bascule clair <-> sombre
  void toggleTheme() {
    _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Fixe explicitement le mode (utile pour persister plus tard si besoin)
  void setThemeMode(ThemeMode mode) {
    _mode = mode;
    notifyListeners();
  }
}
