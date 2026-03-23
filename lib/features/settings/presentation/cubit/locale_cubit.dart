import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the app-wide locale and persists the user's language preference
/// to SharedPreferences so it survives restarts.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._prefs) : super(const Locale('en')) {
    _loadSavedLocale();
  }

  final SharedPreferences _prefs;

  static const _key = 'app_locale';

  void _loadSavedLocale() {
    final languageCode = _prefs.getString(_key) ?? 'en';
    emit(Locale(languageCode));
  }

  /// Changes the app locale and saves the preference.
  void setLocale(Locale locale) {
    _prefs.setString(_key, locale.languageCode);
    emit(locale);
  }
}
