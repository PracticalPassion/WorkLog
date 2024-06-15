import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timing/src/controller/TimeEntryController.dart';
import 'package:timing/src/model/TimeEntry.dart';
import 'package:timing/src/view/pages/FormPage.dart';

class EntryTile extends StatefulWidget {
  final TimeTrackingEntry entry;
  final int dailyWorkHours;
  final bool isZeroHourDay;
  EntryTile({required this.entry, required this.dailyWorkHours, this.isZeroHourDay = false});

  @override
  State<EntryTile> createState() => _EntryTileState();
}

class _EntryTileState extends State<EntryTile> {
  @override
  Widget build(BuildContext context) {
    final workDuration = widget.entry.netDuration;
    final workHours = workDuration.inHours;
    final workMinutes = workDuration.inMinutes % 60;
    final difference = workHours + workMinutes / 60 - widget.entry.expectedWorkHours;
    final date = widget.entry.date;
    final formattedDate = "${date.day}.${date.month}.";
    final formattedWeekDay = getWeekDayName(date.weekday, Localizations.localeOf(context));

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
              width: 55,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // default font size minus 2
                  Text(formattedWeekDay,
                      style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                            fontSize: 13,
                            color: widget.isZeroHourDay ? CupertinoColors.activeBlue : CupertinoTheme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          )),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.entry.timeEntries.map((timeEntry) {
                      final formattedStartTime = _formatTime(timeEntry.start);
                      final formattedEndTime = _formatTime(timeEntry.end);
                      return GestureDetector(
                        onTap: () => showCupertinoModalPopup(useRootNavigator: true, context: context, builder: (context) => bottomSheet(timeEntry)),
                        child: Dismissible(
                          dismissThresholds: const {DismissDirection.endToStart: 0.6},
                          key: ValueKey(timeEntry.id),
                          background: Container(
                              padding: const EdgeInsets.all(10),
                              color: CupertinoColors.systemRed,
                              child: Align(alignment: Alignment.centerRight, child: Text("Delete", style: const CupertinoTextThemeData().textStyle.copyWith(color: CupertinoColors.white)))),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            if (direction == DismissDirection.endToStart) {
                              Provider.of<TimeTrackingController>(context, listen: false).deleteEntry(timeEntry.id);
                            }
                          },
                          child: CupertinoListTile(
                            title: Text(
                              '$formattedStartTime - $formattedEndTime',
                              style: CupertinoTheme.of(context).textTheme.textStyle,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  // const SizedBox(height: 8),
                  // Text(widget.entry.description, style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle),
                ],
              ),
            ),
            // Right section
            Container(
              width: 55,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(workHours == 0 && workMinutes == 0 ? "" : '$workHours:${workMinutes.toString().padLeft(2, '0')} h', style: CupertinoTheme.of(context).textTheme.textStyle),
                  Text(
                    workHours == 0 && workMinutes == 0 ? "" : '${difference.toStringAsFixed(2)} h',
                    style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.copyWith(
                          fontSize: 12,
                          color: difference >= 0 ? CupertinoTheme.of(context).primaryColor : CupertinoColors.systemRed,
                        ),
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

  Widget bottomSheet(timeEntry) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(15),
            ),
          ),
          child: EntryFormPage(entry: timeEntry)));
}
