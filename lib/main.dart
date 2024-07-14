import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:work_log/src/controller/TimeEntryController.dart';
import 'package:work_log/src/controller/purchase.dart';
import 'package:work_log/src/controller/purchase/purchase.dart';
import 'package:work_log/src/controller/settingsController.dart';
import 'package:work_log/src/controller/setupController.dart';
import 'package:work_log/src/model/database/database.dart';
import 'package:work_log/src/view/pages/intro/FirstIntro.dart';
import 'package:work_log/src/view/pages/home/home.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().initDatabase();
  await PurchaseApi.init();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => SettingsController()),
    ChangeNotifierProvider(create: (_) => TimeTrackingController()),
    ChangeNotifierProvider(create: (_) => SetupModel()),
    ChangeNotifierProvider(create: (_) => PurchaseController()),
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
        title: 'WorkTrack Pro',
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: getLightTheme(),
        navigatorKey: navigatorKey,
        home: const TimeTrackingApp(),
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
      scaffoldBackgroundColor: const Color.fromARGB(255, 214, 225, 217),
      barBackgroundColor: const Color.fromARGB(255, 189, 191, 189),
      applyThemeToAll: true,
    );
  }

  CupertinoTextThemeData getTextTheme() {
    return CupertinoTextThemeData(
      textStyle: const CupertinoTextThemeData().textStyle.copyWith(color: CupertinoColors.black, fontSize: 15),
    );
  }
}

class TimeTrackingApp extends StatefulWidget {
  const TimeTrackingApp({super.key});

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
    final purchseController = Provider.of<PurchaseController>(context, listen: false);
    purchseController.updateStatus(context);
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const CupertinoActivityIndicator()
        : settingsController.settings == null
            ? FirstPage()
            : const TimeTrackingListPage();
  }
}
