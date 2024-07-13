import 'package:work_log/src/controller/purchase/constant.dart';

class AppData {
  static final AppData _appData = AppData._internal();

  bool entitlementIsActive = false;
  String appUserID = '';
  Plan plan = Plan.test;

  factory AppData() {
    return _appData;
  }
  AppData._internal();
}

final appData = AppData();
