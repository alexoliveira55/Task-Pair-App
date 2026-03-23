import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key for SharedPreferences
const _localeKey = 'app_locale';

/// Supported locales
const supportedLocales = [
  Locale('pt', 'BR'),
  Locale('en'),
];

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_localeKey);
    if (saved != null) {
      final parts = saved.split('_');
      state = parts.length > 1 ? Locale(parts[0], parts[1]) : Locale(parts[0]);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _localeKey,
      locale.countryCode != null
          ? '${locale.languageCode}_${locale.countryCode}'
          : locale.languageCode,
    );
  }

  Future<void> setSystemDefault() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localeKey);
  }

  /// Resolves the effective locale (for use in MaterialApp)
  static Locale resolveLocale(Locale? override) {
    if (override != null) return override;

    final systemLocale = PlatformDispatcher.instance.locale;

    // Check if system locale is supported
    if (systemLocale.languageCode == 'pt') {
      return const Locale('pt', 'BR');
    }
    if (systemLocale.languageCode == 'en') {
      return const Locale('en');
    }

    // Fallback to Portuguese (Brazil)
    return const Locale('pt', 'BR');
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier();
});
