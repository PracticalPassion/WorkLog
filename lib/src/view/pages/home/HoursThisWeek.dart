import 'package:flutter/cupertino.dart';
import 'package:work_log/src/view/macros/ContentView.dart';
import 'package:work_log/src/view/pages/home/InfoTile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HoursThisWeekWidget extends StatelessWidget {
  final double weeklyHours;

  HoursThisWeekWidget({required this.weeklyHours});

  @override
  Widget build(BuildContext context) {
    return ContentView(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      padding: const EdgeInsets.all(10),
      child: InfoTile(
        title: AppLocalizations.of(context)!.hoursThisWeek,
        value: '${weeklyHours.toStringAsFixed(2)} h',
      ),
    );
  }
}
