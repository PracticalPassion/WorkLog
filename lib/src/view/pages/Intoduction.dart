import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:timing/src/controller/settingsController.dart';
import 'package:timing/src/model/UserSettings.dart';
import 'package:timing/src/view/Helper/Extentions/DurationExtention.dart';
import 'package:timing/src/view/Helper/Utils.dart';
import 'package:timing/src/view/macros/DateTimePicker/DateTimePicker.dart';
import 'package:timing/src/view/macros/TemplateRow.dart';
import 'package:timing/src/view/pages/home/Add/FormTemplate.dart';
import 'package:timing/src/view/pages/home/home.dart';
import 'package:intl/intl.dart';

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
    DateTime.sunday: Duration(hours: 1),
  };

  int breakDurationMinutes = 30;
  Duration breakAfterHours = Duration(hours: 6);

  String getDayName(int weekday) {
    DateTime referenceDate = DateTime(2022, 1, 3 + (weekday - DateTime.monday));

    return DateFormat.EEEE(Localizations.localeOf(context).toString()).format(referenceDate);
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = Provider.of<SettingsController>(context);

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(context),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              FormLayout(
                showDividers: true,
                title: "Time sheet settings",
                children: [
                  ...sortedWeekDays.map((day) {
                    return TemplateRow(
                      leftName: getDayName(day),
                      rightTextWidget: Text(dailyWorkingHours[day]!.formatDarationH2M()), // Annahme: formatDurationH2M ist eine Methode von Duration
                      rightTextOnPressed: () {
                        showFilterWidget(context, dailyWorkingHours[day]!, (time) {
                          setState(() {
                            dailyWorkingHours[day] = time;
                          });
                        });
                      },
                    );
                  })
                ],
              ),
              FormLayout(showDividers: true, title: null, children: [
                TemplateRow(
                  leftName: ('Break Duration (minutes)'),
                  rightTextWidget: Text(breakDurationMinutes.toString()),
                  rightTextOnPressed: () {
                    showFilterMinuteWidget(context, Duration(minutes: breakDurationMinutes), (time) {
                      setState(() {
                        breakDurationMinutes = time.inMinutes;
                      });
                    });
                  },
                ),
                TemplateRow(
                  leftName: ('Break After (hours)'),
                  rightTextWidget: Text(breakAfterHours.formatDarationH2M()),
                  rightTextOnPressed: () {
                    showFilterWidget(context, breakAfterHours, (time) {
                      setState(() {
                        breakAfterHours = time;
                      });
                    });
                  },
                ),
              ]),
              CupertinoButton.filled(
                child: Text('Save'),
                onPressed: () async {
                  final settings = UserSettings(
                    dailyWorkingHours: dailyWorkingHours,
                    breakDurationMinutes: breakDurationMinutes,
                    breakAfterHours: breakAfterHours,
                  );
                  await settingsController.saveUserSettings(settings);

                  Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(builder: (context) => TimeTrackingListPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showFilterWidget(BuildContext context, Duration time, Function(Duration) onPressed) {
    Utils.showSheet(
      context,
      child: SizedBox(
        height: 250,
        child: DurationPicker(
          initialDuration: time,
          onDurationChanged: (Duration newDateTime) {
            onPressed(newDateTime);
            setState(() {
              time = newDateTime;
            });
          },
        ),
      ),
      onClicked: () {
        onPressed(time);
        Navigator.of(context).pop();
      },
    );
  }

  void showFilterMinuteWidget(BuildContext context, Duration time, Function(Duration) onPressed) {
    Utils.showSheet(
      context,
      child: SizedBox(
        height: 250,
        child: DurationPickerMinute(
          initialDuration: time,
          onDurationChanged: (Duration newDateTime) {
            onPressed(newDateTime);
            setState(() {
              time = newDateTime;
            });
          },
        ),
      ),
      onClicked: () {
        onPressed(time);
        Navigator.of(context).pop();
      },
    );
  }
}
