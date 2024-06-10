import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:timing/src/model/TimeEntry.dart';

class EntryTile extends StatelessWidget {
  final TimeTrackingEntry entry;
  final int dailyWorkHours;
  final bool isZeroHourDay;
  EntryTile({required this.entry, required this.dailyWorkHours, this.isZeroHourDay = false});

  @override
  Widget build(BuildContext context) {
    final workDuration = entry.netDuration;
    final workHours = workDuration.inHours;
    final workMinutes = workDuration.inMinutes % 60;
    final difference = workHours + workMinutes / 60 - entry.expectedWorkHours;
    final date = entry.firstStartEntry.start;
    final formattedDate = "${date.day}.${date.month}.";
    final formattedWeekDay = getWeekDayName(date.weekday, Localizations.localeOf(context));
    final formattedStartTime = _formatTime(entry.firstStartEntry.start);
    final formattedEndTime = _formatTime(entry.lastStartEntry.end);

    return Container(
      // border below each entry
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color.fromARGB(255, 223, 223, 229),
            width: 1,
          ),
        ),
      ),

      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left section
            SizedBox(
              width: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // default font size minus 2
                  Text(formattedWeekDay,
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .textStyle
                          .copyWith(fontSize: 13, color: isZeroHourDay ? CupertinoColors.activeBlue : Color.fromARGB(255, 74, 176, 111), fontWeight: FontWeight.bold)),
                  Text(formattedDate, style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Middle section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(workHours == 0 && workMinutes == 0 ? "" : '$formattedStartTime - $formattedEndTime', style: CupertinoTheme.of(context).textTheme.textStyle),
                  const SizedBox(height: 1),
                  Text(entry.description, style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle),
                ],
              ),
            ),
            // Right section
            Container(
              width: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(workHours == 0 && workMinutes == 0 ? "" : '$workHours:${workMinutes.toString().padLeft(2, '0')} h', style: CupertinoTheme.of(context).textTheme.textStyle),
                  Text(
                    workHours == 0 && workMinutes == 0 ? "" : '${difference.toStringAsFixed(2)} h',
                    style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.copyWith(fontSize: 12, color: difference >= 0 ? Color.fromARGB(255, 74, 176, 111) : CupertinoColors.systemRed),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  String getWeekDayName(int day, Locale locale) {
    // Erstellt ein Datum für den gewünschten Tag
    DateTime date = DateTime(2024, 1, day);
    // Nutzt DateFormat für die Kurzform des Wochentags
    DateFormat dateFormat = DateFormat.E(locale.toString());
    return dateFormat.format(date);
  }
}
