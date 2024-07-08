import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:timing/src/controller/TimeEntryController.dart';
import 'package:timing/src/controller/settingsController.dart';
import 'package:timing/src/controller/setupController.dart';
import 'package:timing/src/model/database/database.dart';
import 'package:timing/src/view/pages/intro/FirstIntro.dart';
import 'package:timing/src/view/pages/home/home.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Hive.initFlutter();
  // await initApp();

  await DatabaseHelper().initDatabase();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => SettingsController()),
    ChangeNotifierProvider(create: (_) => TimeTrackingController()),
    ChangeNotifierProvider(create: (_) => SetupModel()),
  ], child: const App()));
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      return CupertinoApp(
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('de', 'DE'),
        ],
        debugShowCheckedModeBanner: false,
        title: 'Time Tracking App',
        localizationsDelegates: const [
          AppLocalizations.delegate,
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
      scaffoldBackgroundColor: Color.fromARGB(255, 214, 225, 217),
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
            ? FirstPage()
            : TimeTrackingListPage();
  }
}
