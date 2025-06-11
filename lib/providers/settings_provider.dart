import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>((ref) {
  return SettingsNotifier();
});

class Settings {
  final ThemeMode themeMode;
  final Locale locale;

  Settings({
    required this.themeMode,
    required this.locale,
  });

  Settings copyWith({
    ThemeMode? themeMode,
    Locale? locale,
  }) {
    return Settings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}

class SettingsNotifier extends StateNotifier<Settings> {
  static const _themeKey = 'theme_mode';
  static const _localeKey = 'locale';

  SettingsNotifier() : super(Settings(
    themeMode: ThemeMode.system,
    locale: const Locale('it'),
  )) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load theme
    final themeIndex = prefs.getInt(_themeKey);
    final themeMode = themeIndex != null ? ThemeMode.values[themeIndex] : ThemeMode.system;
    
    // Load locale
    final localeString = prefs.getString(_localeKey);
    final locale = localeString != null ? Locale(localeString) : const Locale('it');
    
    state = Settings(
      themeMode: themeMode,
      locale: locale,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    state = state.copyWith(locale: locale);
  }
} 