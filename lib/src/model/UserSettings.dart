import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettings {
  Map<int, double> dailyWorkingHours;
  int breakDurationMinutes;
  int breakAfterHours;

  UserSettings({
    required this.dailyWorkingHours,
    required this.breakDurationMinutes,
    required this.breakAfterHours,
  });

  Map<String, dynamic> toMap() {
    return {
      'dailyWorkingHours': dailyWorkingHours.map((key, value) => MapEntry(key.toString(), value)),
      'breakDurationMinutes': breakDurationMinutes,
      'breakAfterHours': breakAfterHours,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      dailyWorkingHours: Map<int, double>.from(map['dailyWorkingHours'].map((key, value) => MapEntry(int.parse(key), value))),
      breakDurationMinutes: map['breakDurationMinutes'],
      breakAfterHours: map['breakAfterHours'],
    );
  }
}

class SettingsHelper {
  static const String SETTINGS_KEY = 'user_settings';

  static Future<void> saveUserSettings(UserSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SETTINGS_KEY, jsonEncode(settings.toMap()));
  }

  static Future<UserSettings?> getUserSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsString = prefs.getString(SETTINGS_KEY);
    if (settingsString == null) return null;
    final settingsMap = jsonDecode(settingsString);
    return UserSettings.fromMap(settingsMap);
  }

  static Future<double> getWorkingHours(int weekday) async {
    UserSettings? settings = await getUserSettings();

    if (settings == null) return 0;
    return settings.dailyWorkingHours[weekday] ?? 0;
  }
}
