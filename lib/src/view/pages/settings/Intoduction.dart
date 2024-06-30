import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:timing/src/view/pages/home/home.dart';
import 'package:timing/src/view/pages/settings/TimeSheetSettingsWidget.dart';

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
  Duration breakAfterHours = Duration(hours: 6);

  String getDayName(int weekday) {
    DateTime referenceDate = DateTime(2022, 1, 3 + (weekday - DateTime.monday));

    return DateFormat.EEEE(Localizations.localeOf(context).toString()).format(referenceDate);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(context),
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
                dailyWorkingHours.addAll(newDailyWorkingHours);
                breakDurationMinutes = newBreakDurationMinutes;
                breakAfterHours = newBreakAfterHours;
              });
            },
            afterSuccess: () {
              Navigator.pushReplacement(
                context,
                CupertinoPageRoute(builder: (context) => TimeTrackingListPage()),
              );
            },
          ),
        ),
      ),
    );
  }
}
