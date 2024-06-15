import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:timing/src/controller/settingsController.dart';
import 'package:timing/src/model/UserSettings.dart';
import 'package:timing/src/view/pages/home/home.dart';

class IntroductionPage extends StatefulWidget {
  @override
  _IntroductionPageState createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  final Map<String, int> dailyWorkingHours = {
    'Monday': 8,
    'Tuesday': 8,
    'Wednesday': 8,
    'Thursday': 8,
    'Friday': 8,
    'Saturday': 0,
    'Sunday': 0,
  };
  int breakDurationMinutes = 30;
  int breakAfterHours = 6;

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
                prefix: Text(day),
                initialValue: dailyWorkingHours[day].toString(),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    dailyWorkingHours[day] = int.tryParse(value) ?? 0;
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
