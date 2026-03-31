import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService {
  static const String _localeKey = 'app_locale';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setLocale(String languageCode) async {
    await _prefs?.setString(_localeKey, languageCode);
  }

  static String? getLocaleCode() {
    return _prefs?.getString(_localeKey);
  }

  static Locale? getLocale() {
    final code = getLocaleCode();
    if (code != null) return Locale(code);
    return null;
  }
}
