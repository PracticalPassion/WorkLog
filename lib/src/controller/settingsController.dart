import 'package:flutter/cupertino.dart';
import 'package:work_log/src/model/UserSettings.dart';

class SettingsController extends ChangeNotifier {
  UserSettings? _settings;

  UserSettings? get settings => _settings;

  Future<void> loadUserSettings() async {
    // await deleteUserSettings();
    _settings = await SettingsHelper.getUserSettings();
    notifyListeners();
  }

  Future<void> saveUserSettings(UserSettings settings) async {
    await SettingsHelper.saveUserSettings(settings);
    _settings = settings;
    notifyListeners();
  }

  Future<void> deleteUserSettings() async {
    await SettingsHelper.deleteUserSettings();
    _settings = null;
    notifyListeners();
  }

  Duration getExpectedWorkHours(DateTime date) {
    return _settings!.getExpectedWorkHours(date);
  }
}
