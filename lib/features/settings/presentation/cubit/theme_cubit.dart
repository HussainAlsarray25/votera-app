import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the app-wide theme mode (light / dark) and persists the
/// user's preference to SharedPreferences so it survives restarts.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs) : super(ThemeMode.dark) {
    _loadSavedTheme();
  }

  final SharedPreferences _prefs;

  static const _key = 'app_theme_mode';

  void _loadSavedTheme() {
    final isDark = _prefs.getBool(_key) ?? true;
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  /// Switches between light and dark, saving the new preference.
  void toggleTheme() {
    final isDark = state == ThemeMode.dark;
    _prefs.setBool(_key, !isDark);
    emit(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  bool get isDark => state == ThemeMode.dark;
}
