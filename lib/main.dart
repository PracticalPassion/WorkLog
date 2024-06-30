import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:timing/src/controller/TimeEntryController.dart';
import 'package:timing/src/controller/settingsController.dart';
import 'package:timing/src/model/database/database.dart';
import 'package:timing/src/view/pages/settings/Intoduction.dart';
import 'package:timing/src/view/pages/home/home.dart';
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
  bool loading = true;

  Future<void> loadSettings() async {
    await settingsController.loadUserSettings();
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? CupertinoActivityIndicator()
        : settingsController.settings == null
            ? IntroductionPage()
            : TimeTrackingListPage();
  }
}
