import 'package:shared_preferences/shared_preferences.dart';

class UserDataService {
  static const String _birthDateKey = 'user_birth_date';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveBirthDate(DateTime date) async {
    await _prefs?.setString(_birthDateKey, date.toIso8601String());
  }

  static DateTime? getBirthDate() {
    final dateStr = _prefs?.getString(_birthDateKey);
    if (dateStr != null) {
      return DateTime.tryParse(dateStr);
    }
    return null;
  }

  static bool hasBirthDate() {
    return _prefs?.containsKey(_birthDateKey) ?? false;
  }

  static Future<void> clearBirthDate() async {
    await _prefs?.remove(_birthDateKey);
  }
}
