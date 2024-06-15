import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:timing/src/controller/TimeEntryController.dart';
import 'package:timing/src/controller/settingsController.dart';
import 'package:timing/src/model/UserSettings.dart';
import 'package:timing/src/model/database/database.dart';
import 'package:timing/src/view/Intoduction.dart';
import 'package:timing/src/view/pages/home/home.dart';
// import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

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
        locale: const Locale('de', 'DE'), // Standard auf Deutsch setzen
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('de', 'DE'),
          // Weitere unterstützte Locales hinzufügen
        ],
        debugShowCheckedModeBanner: false,
        title: 'Time Tracking App',
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: getLightTheme(),
        navigatorKey: navigatorKey,
        home: TimeTrackingApp(),
      );
    } on Exception catch (_) {
      throw UnimplementedError();
    }
  }

  CupertinoThemeData getLightTheme() {
    return CupertinoThemeData(
      brightness: Brightness.light,
      textTheme: getTextTheme(),
      primaryColor: const Color.fromARGB(255, 61, 140, 90),
      primaryContrastingColor: CupertinoColors.white,
      scaffoldBackgroundColor: const Color.fromARGB(255, 193, 215, 199),
      barBackgroundColor: CupertinoColors.systemBlue,
      applyThemeToAll: true,
    );
  }

  CupertinoTextThemeData getTextTheme() {
    return CupertinoTextThemeData(textStyle: CupertinoTextThemeData().textStyle.copyWith(fontSize: 16, color: CupertinoColors.black));
  }
}

class TimeTrackingApp extends StatefulWidget {
  @override
  _TimeTrackingAppState createState() => _TimeTrackingAppState();
}

class _TimeTrackingAppState extends State<TimeTrackingApp> {
  final settingsController = SettingsController();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsController>(
      builder: (context, settingsController, _) {
        if (settingsController.settings == null) {
          settingsController.loadUserSettings();
          return const CupertinoPageScaffold(
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
