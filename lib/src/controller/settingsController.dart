import 'package:flutter/cupertino.dart';
import 'package:timing/src/model/UserSettings.dart';

class SettingsController extends ChangeNotifier {
  UserSettings? _settings;

  UserSettings? get settings => _settings;

  Future<void> loadUserSettings() async {
    _settings = await SettingsHelper.getUserSettings();
    if (_settings == null) {
      // Default settings if none are found
      _settings = UserSettings(
        dailyWorkingHours: {
          'Monday': 8,
          'Tuesday': 8,
          'Wednesday': 8,
          'Thursday': 8,
          'Friday': 8,
          'Saturday': 0,
          'Sunday': 0,
        },
        breakDurationMinutes: 30,
        breakAfterHours: 6,
      );
    }
    notifyListeners();
  }

  Future<void> saveUserSettings(UserSettings settings) async {
    await SettingsHelper.saveUserSettings(settings);
    _settings = settings;
    notifyListeners();
  }
}
