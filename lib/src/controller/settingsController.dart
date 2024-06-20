import 'package:flutter/cupertino.dart';
import 'package:timing/src/model/UserSettings.dart';

class SettingsController extends ChangeNotifier {
  UserSettings? _settings;

  UserSettings? get settings => _settings;

  Future<void> loadUserSettings() async {
    _settings = await SettingsHelper.getUserSettings();
    _settings ??= UserSettings(
      dailyWorkingHours: {
        DateTime.monday: 8,
        DateTime.tuesday: 8,
        DateTime.wednesday: 8,
        DateTime.thursday: 8,
        DateTime.friday: 8,
        DateTime.saturday: 0,
        DateTime.sunday: 0,
      },
      breakDurationMinutes: 30,
      breakAfterHours: 6,
    );
    notifyListeners();
  }

  Future<void> saveUserSettings(UserSettings settings) async {
    await SettingsHelper.saveUserSettings(settings);
    _settings = settings;
    notifyListeners();
  }

  double getExpectedWorkHours(DateTime date) {
    return _settings?.dailyWorkingHours[date.weekday] ?? 0;
  }
}
