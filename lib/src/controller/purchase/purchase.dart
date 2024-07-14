import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_log/src/controller/purchase/AppData.dart';
import 'package:work_log/src/controller/purchase/PayWall.dart';
import 'package:work_log/src/controller/purchase/constant.dart';
import 'package:work_log/src/controller/purchase/storeConfig.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PurchaseApi {
  static const String trialStartDateKey = 'trial_start_date';

  static Future init() async {
    await Purchases.setLogLevel(LogLevel.debug);
    if (Platform.isIOS || Platform.isMacOS) {
      StoreConfig(
        store: Store.appStore,
        apiKey: appleAPIKey,
      );
      //   } else if (Platform.isAndroid) {
      //     // Run the app passing --dart-define=AMAZON=true
      //     const useAmazon = bool.fromEnvironment("amazon");
      //     StoreConfig(
      //       store: useAmazon ? Store.amazon : Store.playStore,
      //       apiKey: useAmazon ? amazonApiKey : googleApiKey,
      //     );

      PurchasesConfiguration configuration;
      if (StoreConfig.isForAmazonAppstore()) {
        configuration = AmazonConfiguration(StoreConfig.instance.apiKey)
          ..appUserID = null
          ..observerMode = false;
      } else {
        configuration = PurchasesConfiguration(StoreConfig.instance.apiKey)
          ..appUserID = null
          ..observerMode = false;
      }
      await Purchases.configure(configuration);
    }
  }

  static Future<List<Offering>> fetchOfferrs() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      return current == null ? [] : [current];
    } on PlatformException {
      return [];
    }
  }

  static Future<void> restorePurchases(context) async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      // ... check restored purchaserInfo to see if entitlement is now active

      EntitlementInfo? entitlement = customerInfo.entitlements.all[entitlementID];
      appData.entitlementIsActive = entitlement?.isActive ?? false;
      appData.plan = appData.entitlementIsActive ? Plan.pro : Plan.test;

      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(AppLocalizations.of(context)!.success),
            content: Text(AppLocalizations.of(context)!.restoreSuccess),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(AppLocalizations.of(context)!.ok),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    } on PlatformException catch (e) {
      // Error restoring purchases
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(AppLocalizations.of(context)!.error),
            content: Text(AppLocalizations.of(context)!.restoreFail),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(AppLocalizations.of(context)!.ok),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    }
  }

  static Future<bool> accessGuaranteed(context) async {
    if (!appData.entitlementIsActive) {
      // Überprüfe, ob der Nutzer die App zum ersten Mal nutzt
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? trialStartDateString = prefs.getString(trialStartDateKey);

      if (trialStartDateString == null) {
        // Speichere das Startdatum der Testphase
        DateTime trialStartDate = DateTime.now();
        await prefs.setString(trialStartDateKey, trialStartDate.toIso8601String());
      } else {
        DateTime trialStartDate = DateTime.parse(trialStartDateString);
        DateTime oneWeekLater = trialStartDate.add(daysTestPhase);

        if (DateTime.now().isAfter(oneWeekLater)) {
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
                      await perfomMagic(context);
                    },
                  ),
                ],
              );
            },
          );
          return false;
        }
      }
    }
    return true;
  }

  static Future<int> getRemainingTestDays() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? trialStartDateString = prefs.getString(trialStartDateKey);

    if (trialStartDateString == null) {
      return daysTestPhase.inDays;
    } else {
      DateTime trialStartDate = DateTime.parse(trialStartDateString);
      DateTime later = trialStartDate.add(daysTestPhase);

      if (DateTime.now().isAfter(later)) {
        return 0;
      } else {
        return later.difference(DateTime.now()).inDays;
      }
    }
  }

  static Future<void> initPlatformState() async {
    appData.appUserID = await Purchases.appUserID;

    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      appData.appUserID = await Purchases.appUserID;

      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      EntitlementInfo? entitlement = customerInfo.entitlements.all[entitlementID];
      appData.entitlementIsActive = entitlement?.isActive ?? false;
      appData.plan = appData.entitlementIsActive ? Plan.pro : Plan.test;
    });
  }

  static Future<void> perfomMagic(context) async {
    CustomerInfo customerInfo = await Purchases.getCustomerInfo();

    if (customerInfo.entitlements.all[entitlementID] != null && customerInfo.entitlements.all[entitlementID]?.isActive == true) {
      await showCupertinoDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
                  title: Text(
                    AppLocalizations.of(context)!.success,
                    style: TextStyle(fontFamily: GoogleFonts.robotoMono().fontFamily),
                  ),
                  content: Text(
                    AppLocalizations.of(context)!.subscriptionActive,
                    style: TextStyle(fontFamily: GoogleFonts.robotoMono().fontFamily),
                  ),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      child: Text(AppLocalizations.of(context)!.ok),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ]));
    } else {
      Offerings? offerings;
      try {
        offerings = await Purchases.getOfferings();
      } on PlatformException {
        await showCupertinoDialog(
            context: context,
            builder: (BuildContext context) => CupertinoAlertDialog(
                    title: Text(
                      AppLocalizations.of(context)!.error,
                      style: TextStyle(fontFamily: GoogleFonts.robotoMono().fontFamily),
                    ),
                    content: Text(
                      AppLocalizations.of(context)!.errorFetchOffers,
                      style: TextStyle(fontFamily: GoogleFonts.robotoMono().fontFamily),
                    ),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        isDefaultAction: true,
                        child: Text(AppLocalizations.of(context)!.ok),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ]));
      }

      if (offerings == null || offerings.current == null) {
        // offerings are empty, show a message to your user
        await showCupertinoDialog(
            context: context,
            builder: (BuildContext context) => CupertinoAlertDialog(
                    title: Text(
                      AppLocalizations.of(context)!.error,
                      style: TextStyle(fontFamily: GoogleFonts.robotoMono().fontFamily),
                    ),
                    content: Text(
                      AppLocalizations.of(context)!.noProductAvailable,
                      style: TextStyle(fontFamily: GoogleFonts.robotoMono().fontFamily),
                    ),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        isDefaultAction: true,
                        child: Text(AppLocalizations.of(context)!.ok),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ]));
      } else {
        // current offering is available, show paywall
        await showModalBottomSheet(
          useRootNavigator: true,
          isDismissible: true,
          isScrollControlled: true,
          // backgroundColor:
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          ),
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) {
              return Paywall(
                offering: offerings!.current!,
              );
            });
          },
        );
        // update plan
        await PurchaseApi.init();
      }
    }
  }
}
