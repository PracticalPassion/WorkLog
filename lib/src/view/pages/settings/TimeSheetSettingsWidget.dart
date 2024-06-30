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

class TimeSheetSettingsWidget extends StatelessWidget {
  final List<int> sortedWeekDays;
  final Map<int, Duration> dailyWorkingHours;
  final int breakDurationMinutes;
  final Duration breakAfterHours;
  final Function afterSuccess;
  final Function(Map<int, Duration>, int, Duration) onSettingsChanged;

  const TimeSheetSettingsWidget({
    super.key,
    required this.sortedWeekDays,
    required this.dailyWorkingHours,
    required this.breakDurationMinutes,
    required this.breakAfterHours,
    required this.onSettingsChanged,
    required this.afterSuccess,
  });

  String getDayName(BuildContext context, int weekday) {
    DateTime referenceDate = DateTime(2022, 1, 3 + (weekday - DateTime.monday));
    return DateFormat.EEEE(Localizations.localeOf(context).toString()).format(referenceDate);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(0),
      shrinkWrap: true,
      children: [
        FormLayout(
          showDividers: true,
          title: "Time sheet settings",
          children: [
            ...sortedWeekDays.map((day) {
              return TemplateRow(
                leftName: getDayName(context, day),
                rightTextWidget: Text(dailyWorkingHours[day]!.formatDarationH2M()), // Annahme: formatDurationH2M ist eine Methode von Duration
                rightTextOnPressed: () {
                  showFilterWidget(context, dailyWorkingHours[day]!, (time) {
                    onSettingsChanged({day: time}, breakDurationMinutes, breakAfterHours);
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
                onSettingsChanged(dailyWorkingHours, time.inMinutes, breakAfterHours);
              });
            },
          ),
          TemplateRow(
            leftName: ('Break After (hours)'),
            rightTextWidget: Text(breakAfterHours.formatDarationH2M()),
            rightTextOnPressed: () {
              showFilterWidget(context, breakAfterHours, (time) {
                onSettingsChanged(dailyWorkingHours, breakDurationMinutes, time);
              });
            },
          ),
        ]),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 100),
          child: CupertinoButton.filled(
            child: Text('Save'),
            onPressed: () async {
              final settings = UserSettings(
                dailyWorkingHours: dailyWorkingHours,
                breakDurationMinutes: breakDurationMinutes,
                breakAfterHours: breakAfterHours,
              );
              final settingsController = Provider.of<SettingsController>(context, listen: false);
              await settingsController.saveUserSettings(settings);

              afterSuccess();
            },
          ),
        ),
        const SizedBox(height: 0)
      ],
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
            time = newDateTime;

            onPressed(newDateTime);
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
            time = newDateTime;
            onPressed(newDateTime);
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
