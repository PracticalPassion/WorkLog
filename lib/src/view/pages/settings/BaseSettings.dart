import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:work_log/src/controller/settingsController.dart';
import 'package:intl/intl.dart';
import 'package:work_log/src/model/UserSettings.dart';
import 'package:work_log/src/view/pages/settings/TimeSheetSettingsWidget.dart';

class BaseSettings extends StatefulWidget {
  const BaseSettings({super.key});

  @override
  _BaseSettingsState createState() => _BaseSettingsState();
}

class _BaseSettingsState extends State<BaseSettings> {
  final List<int> sortedWeekDays = [
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
    DateTime.saturday,
    DateTime.sunday,
  ];
  late Map<int, Duration> dailyWorkingHours = {};
  late int breakDurationMinutes;
  late Duration breakAfterHours;

  @override
  void initState() {
    super.initState();
    final settingsController = Provider.of<SettingsController>(context, listen: false);
    UserSettings settings = settingsController.settings!;
    dailyWorkingHours = settings.dailyWorkingHours;
    breakDurationMinutes = settings.breakDurationMinutes;
    breakAfterHours = settings.breakAfterHours;
  }

  String getDayName(int weekday) {
    DateTime referenceDate = DateTime(2022, 1, 3 + (weekday - DateTime.monday));

    return DateFormat.EEEE(Localizations.localeOf(context).toString()).format(referenceDate);
  }

  @override
  Widget build(BuildContext context) {
    return TimeSheetSettingsWidget(
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
      afterSuccess: () => Navigator.pop(context),
    );
  }
}
