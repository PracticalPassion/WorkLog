import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettings {
  Map<int, Duration> dailyWorkingHours;
  int breakDurationMinutes;
  Duration breakAfterHours;

  UserSettings({
    required this.dailyWorkingHours,
    required this.breakDurationMinutes,
    required this.breakAfterHours,
  });

  Map<String, dynamic> toMap() {
    return {
      'dailyWorkingHours': dailyWorkingHours.map((key, value) => MapEntry(key.toString(), value.inMinutes)),
      'breakDurationMinutes': breakDurationMinutes,
      'breakAfterHours': breakAfterHours.inMinutes,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      dailyWorkingHours: Map<int, Duration>.from(map['dailyWorkingHours'].map((key, value) => MapEntry(int.parse(key), Duration(minutes: value)))),
      breakDurationMinutes: map['breakDurationMinutes'],
      breakAfterHours: Duration(minutes: map['breakAfterHours']),
    );
  }

  Duration getExpectedWorkHours(DateTime date) {
    return dailyWorkingHours[date.weekday]!;
  }
}

class SettingsHelper {
  static const String SETTINGS_KEY = 'user_settings';

  static Future<void> saveUserSettings(UserSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    var map = settings.toMap();
    await prefs.setString(SETTINGS_KEY, jsonEncode(map));
  }

  static Future<UserSettings?> getUserSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsString = prefs.getString(SETTINGS_KEY);
    if (settingsString == null) return null;
    final settingsMap = jsonDecode(settingsString);
    return UserSettings.fromMap(settingsMap);
  }

  static Future<void> deleteUserSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(SETTINGS_KEY);
  }
}
