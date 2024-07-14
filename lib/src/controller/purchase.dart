import 'package:flutter/cupertino.dart';
import 'package:work_log/src/controller/purchase/AppData.dart';
import 'package:work_log/src/controller/purchase/purchase.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PurchaseController extends ChangeNotifier {
  bool _accessGranted = false;

  bool access(context) {
    if (appData.entitlementIsActive) {
      return true;
    }

    if (!_accessGranted) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(AppLocalizations.of(context)!.expiredTestTitle),
            content: Text(AppLocalizations.of(context)!.expiredTestText),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(AppLocalizations.of(context)!.decline),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                child: Text(AppLocalizations.of(context)!.yes),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await PurchaseApi.perfomMagic(context);
                },
              ),
            ],
          );
        },
      );
      return false;
    }
    updateStatus(context);
    return true;
  }

  set accessGranted(bool value) {
    _accessGranted = value;
    notifyListeners();
  }

  void updateStatus(context) async {
    bool gurant = await PurchaseApi.accessGuaranteed(context);
    accessGranted = gurant;
    notifyListeners();
  }
}
