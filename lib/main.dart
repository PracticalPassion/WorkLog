import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:timing/src/controller/TimeEntryController.dart';
import 'package:timing/src/controller/settingsController.dart';
import 'package:timing/src/model/UserSettings.dart';
import 'package:timing/src/model/database/database.dart';
import 'package:timing/src/view/Intoduction.dart';
import 'package:timing/src/view/home.dart';
// import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Hive.initFlutter();
  // await initApp();

  await DatabaseHelper().initDatabase();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => SettingsController()),
    ChangeNotifierProvider(create: (_) => TimeTrackingController()),
  ], child: const App()));
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      return CupertinoApp(
        // remove debug banner
        debugShowCheckedModeBanner: false,
        title: 'Time Tracking App',
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: CupertinoThemeData(brightness: Brightness.light, textTheme: CupertinoTextThemeData(textStyle: CupertinoTextThemeData().textStyle.copyWith(fontSize: 15, color: CupertinoColors.black))),
        navigatorKey: navigatorKey,
        home: TimeTrackingApp(),
      );
    } on Exception catch (_) {
      throw UnimplementedError();
    }
  }
}

class TimeTrackingApp extends StatelessWidget {
  final settingsController = SettingsController();

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsController>(
      builder: (context, settingsController, _) {
        if (settingsController.settings == null) {
          settingsController.loadUserSettings();
          return CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator()),
          );
        } else {
          return settingsController.settings == null ? IntroductionPage() : TimeTrackingListPage();
        }
      },
    );
  }
}

// Future<void> initApp() async {
//   await Hive.initFlutter();
//   Hive.registerAdapter(ZoneAdapter());
//   await Hive.openBox<Zone>('zoneBox');
//   await Hive.openBox('settings');
//   await _initializeZonesIfNeeded();
// }

// Future<void> _initializeZonesIfNeeded() async {
//   var settingsBox = Hive.box('settings');
//   if (settingsBox.get('isFirstRun', defaultValue: true)) {
//     final List<Zone> zones = [
//       Zone(zone: ZoneType.zone1, from: 110, to: 135),
//       Zone(zone: ZoneType.zone2, from: 136, to: 149),
//       Zone(zone: ZoneType.zone3, from: 150, to: 162),
//       Zone(zone: ZoneType.zone4, from: 163, to: 175),
//       Zone(zone: ZoneType.zone5, from: 176, to: 195)
//     ];

//     ZoneAdapter.saveZones(zones);

//     await settingsBox.put('isFirstRun', false);
//   }
// }
