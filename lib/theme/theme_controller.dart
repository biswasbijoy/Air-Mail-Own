import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages and persists the application's theme mode (system, light, dark).
class ThemeController extends ChangeNotifier {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  static const String _prefKey = 'app_theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  /// Loads the persisted theme mode from SharedPreferences.
  Future<void> loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved == 'light') {
        _themeMode = ThemeMode.light;
      } else if (saved == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (saved == 'system') {
        _themeMode = ThemeMode.system;
      }
      notifyListeners();
    } catch (_) {
      // Ignore errors reading preferences
    }
  }

  /// Updates the theme mode and persists the choice.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = mode == ThemeMode.light
          ? 'light'
          : (mode == ThemeMode.dark ? 'dark' : 'system');
      await prefs.setString(_prefKey, value);
    } catch (_) {
      // Ignore errors saving preferences
    }
  }

  /// Toggles between light and dark themes based on the active brightness.
  Future<void> toggleTheme([BuildContext? context]) async {
    final bool isDark;
    if (context != null) {
      isDark = Theme.of(context).brightness == Brightness.dark;
    } else {
      isDark = _themeMode == ThemeMode.dark;
    }
    final nextMode = isDark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(nextMode);
  }

  @visibleForTesting
  void resetForTesting() {
    _themeMode = ThemeMode.system;
  }
}
