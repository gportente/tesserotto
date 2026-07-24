import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>((ref) {
  return SettingsNotifier();
});

class Settings {
  final ThemeMode themeMode;
  final Locale locale;
  final bool autoBrightness;
  final String defaultSort; // 'name' or 'openCount'

  Settings({
    required this.themeMode,
    required this.locale,
    this.autoBrightness = true,
    this.defaultSort = 'name',
  });

  Settings copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? autoBrightness,
    String? defaultSort,
  }) {
    return Settings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      autoBrightness: autoBrightness ?? this.autoBrightness,
      defaultSort: defaultSort ?? this.defaultSort,
    );
  }
}

class SettingsNotifier extends StateNotifier<Settings> {
  static const _themeKey = 'theme_mode';
  static const _localeKey = 'locale';
  static const _autoBrightnessKey = 'auto_brightness';
  static const _defaultSortKey = 'default_sort';

  SettingsNotifier()
      : super(Settings(
          themeMode: ThemeMode.system,
          locale: const Locale('it'),
        )) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final themeIndex = prefs.getInt(_themeKey);
    final themeMode =
        themeIndex != null ? ThemeMode.values[themeIndex] : ThemeMode.system;

    final localeString = prefs.getString(_localeKey);
    final locale =
        localeString != null ? Locale(localeString) : const Locale('it');

    state = Settings(
      themeMode: themeMode,
      locale: locale,
      autoBrightness: prefs.getBool(_autoBrightnessKey) ?? true,
      defaultSort: prefs.getString(_defaultSortKey) ?? 'name',
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

  Future<void> setAutoBrightness(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoBrightnessKey, value);
    state = state.copyWith(autoBrightness: value);
  }

  Future<void> setDefaultSort(String sort) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultSortKey, sort);
    state = state.copyWith(defaultSort: sort);
  }
}
