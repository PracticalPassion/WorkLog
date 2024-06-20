import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:timing/src/controller/settingsController.dart';
import 'package:timing/src/model/UserSettings.dart';
import 'package:timing/src/view/pages/home/home.dart';
import 'package:intl/intl.dart';

class IntroductionPage extends StatefulWidget {
  @override
  _IntroductionPageState createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  final Map<int, double> dailyWorkingHours = {
    DateTime.monday: 8,
    DateTime.tuesday: 8,
    DateTime.wednesday: 8,
    DateTime.thursday: 8,
    DateTime.friday: 8,
    DateTime.saturday: 0,
    DateTime.sunday: 0,
  };

  int breakDurationMinutes = 30;
  int breakAfterHours = 6;

  String getDayName(int weekday) {
    return DateFormat.EEEE().format(DateTime(2022, 1, weekday));
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = Provider.of<SettingsController>(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Setup Work Hours'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            ...dailyWorkingHours.keys.map((day) {
              return CupertinoTextFormFieldRow(
                prefix: Text(getDayName(day)),
                initialValue: dailyWorkingHours[day].toString(),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    dailyWorkingHours[day] = double.tryParse(value) ?? 0;
                  });
                },
              );
            }).toList(),
            CupertinoTextFormFieldRow(
              prefix: Text('Break Duration (minutes)'),
              initialValue: breakDurationMinutes.toString(),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  breakDurationMinutes = int.tryParse(value) ?? 30;
                });
              },
            ),
            CupertinoTextFormFieldRow(
              prefix: Text('Break After (hours)'),
              initialValue: breakAfterHours.toString(),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  breakAfterHours = int.tryParse(value) ?? 6;
                });
              },
            ),
            CupertinoButton(
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
    );
  }
}
