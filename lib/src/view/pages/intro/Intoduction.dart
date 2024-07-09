import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:work_log/src/controller/setupController.dart';
import 'package:work_log/src/view/pages/home/home.dart';
import 'package:work_log/src/view/pages/settings/TimeSheetSettingsWidget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class IntroductionPage extends StatefulWidget {
  @override
  _IntroductionPageState createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  final List<int> sortedWeekDays = [
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
    DateTime.saturday,
    DateTime.sunday,
  ];
  final Map<int, Duration> dailyWorkingHours = {
    DateTime.monday: Duration(hours: 8),
    DateTime.tuesday: Duration(hours: 8),
    DateTime.wednesday: Duration(hours: 8),
    DateTime.thursday: Duration(hours: 8),
    DateTime.friday: Duration(hours: 8),
    DateTime.saturday: Duration(hours: 0),
    DateTime.sunday: Duration(hours: 0),
  };

  int breakDurationMinutes = 30;
  Duration breakAfterHours = const Duration(hours: 6);

  String getDayName(int weekday) {
    DateTime referenceDate = DateTime(2022, 1, 3 + (weekday - DateTime.monday));

    return DateFormat.EEEE(Localizations.localeOf(context).toString()).format(referenceDate);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SetupModel>(builder: (context, setupModel, child) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
          leading: CupertinoNavigationBarBackButton(
            previousPageTitle: AppLocalizations.of(context)!.back,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        // backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(context),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TimeSheetSettingsWidget(
              sortedWeekDays: sortedWeekDays,
              dailyWorkingHours: dailyWorkingHours,
              breakDurationMinutes: breakDurationMinutes,
              breakAfterHours: breakAfterHours,
              onSettingsChanged: (newDailyWorkingHours, newBreakDurationMinutes, newBreakAfterHours) {
                setState(() {
                  // newDailyWorkingHours is a string
                  if (newDailyWorkingHours is String) {
                    final newMap = Map<int, Duration>.from(dailyWorkingHours);
                    double hour = (double.parse(newDailyWorkingHours) / 5);
                    int minutes = (hour * 60).toInt();
                    final newDuration = Duration(minutes: (minutes));
                    for (var key in newMap.keys) {
                      if (key > 5) break;
                      newMap[key] = newDuration;
                    }
                    dailyWorkingHours.addAll(newMap);
                  } else {
                    dailyWorkingHours.addAll(newDailyWorkingHours);
                  }
                  breakAfterHours = newBreakAfterHours;
                  breakDurationMinutes = newBreakDurationMinutes;
                });
              },
              detailWidget: setupModel.selectedSetup == 1,
              afterSuccess: () {
                dailyWorkingHours;
                Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(builder: (context) => const TimeTrackingListPage()),
                );
              },
            ),
          ),
        ),
      );
    });
  }
}
