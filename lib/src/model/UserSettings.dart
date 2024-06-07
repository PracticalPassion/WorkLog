import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UserSettings {
  Map<String, int> dailyWorkingHours;
  int breakDurationMinutes;
  int breakAfterHours;

  UserSettings({
    required this.dailyWorkingHours,
    required this.breakDurationMinutes,
    required this.breakAfterHours,
  });

  Map<String, dynamic> toMap() {
    return {
      'dailyWorkingHours': dailyWorkingHours,
      'breakDurationMinutes': breakDurationMinutes,
      'breakAfterHours': breakAfterHours,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      dailyWorkingHours: Map<String, int>.from(map['dailyWorkingHours']),
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
}
