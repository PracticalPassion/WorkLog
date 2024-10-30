import 'package:flutter/cupertino.dart';
import 'package:work_log/src/controller/purchase/AppData.dart';
import 'package:work_log/src/controller/purchase/purchase.dart';

class PurchaseController extends ChangeNotifier {
  bool _accessGranted = false;

  bool access(context) {
    if (appData.entitlementIsActive) {
      return true;
    }

    if (!_accessGranted) {
      updateStatus(context);
      return false;
    }
    updateStatus(context);
    return true;
  }

  set accessGranted(bool value) {
    _accessGranted = value;
    notifyListeners();
  }

  void updateStatus(context, {bool loadOnly = false}) async {
    bool gurant = await PurchaseApi.accessGuaranteed(context, loadOnly: loadOnly);
    accessGranted = gurant;
    notifyListeners();
  }
}
