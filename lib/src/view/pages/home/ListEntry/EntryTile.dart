import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timing/src/controller/TimeEntryController.dart';
import 'package:timing/src/controller/settingsController.dart';
import 'package:timing/src/model/TimeEntry.dart';
import 'package:timing/src/view/macros/BottomSheetTemplate.dart';
import 'package:timing/src/view/pages/home/Add/FormPage.dart';

class EntryTile extends StatefulWidget {
  final TimeTrackingEntry entry;
  EntryTile({required this.entry});

  @override
  State<EntryTile> createState() => _EntryTileState();
}

class _EntryTileState extends State<EntryTile> {
  @override
  Widget build(BuildContext context) {
    final settingsController = Provider.of<SettingsController>(context);
    final timeTrackingController = Provider.of<TimeTrackingController>(context);
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
            Container(
              width: 55,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // default font size minus 2
                  Text(formattedWeekDay,
                      style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                            fontSize: 13,
                            color: settingsController.settings!.dailyWorkingHours[widget.entry.date.weekday]! > 0 ? CupertinoColors.activeBlue : CupertinoTheme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          )),
                  Text(formattedDate, style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(width: 20),
            // Middle section
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // minutes of woekday
                    widget.entry.workDay == null ? const SizedBox() : widget.entry.workDay!.getWidget(context),
                    Column(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.entry.timeEntries.map((timeEntry) {
                        final formattedStartTime = _formatTime(timeEntry.start);
                        final formattedEndTime = _formatTime(timeEntry.end);
                        return GestureDetector(
                          onTap: () => showCupertinoModalPopup(useRootNavigator: true, context: context, builder: (context) => BottomSheetEntryForm(child: EntryFormPage(entry: timeEntry))),
                          // popup to delete or edit
                          onLongPress: () => showCupertinoDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CupertinoAlertDialog(
                                title: const Text('Delete Entry'),
                                content: const Text('Do you really want to delete this entry?'),
                                actions: <Widget>[
                                  CupertinoDialogAction(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  CupertinoDialogAction(
                                    isDestructiveAction: true,
                                    child: const Text('Delete'),
                                    onPressed: () {
                                      timeTrackingController.deleteEntry(timeEntry.id);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          ),

                          child: Container(
                            margin: const EdgeInsets.fromLTRB(8, 8, 0, 0),
                            child: Text(
                              '$formattedStartTime - $formattedEndTime',
                              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(fontSize: 15, fontWeight: FontWeight.w300),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            // Right section
            Container(
              width: 70,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
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

  // Widget contextMenue(BuildContext context) {
  //   return CupertinoContextMenu(
  //     actions: <Widget>[
  //       CupertinoContextMenuAction(
  //         child: const Text('Edit'),
  //         onPressed: () {
  //           Navigator.of(context).pop();
  //         },
  //       ),
  //       CupertinoContextMenuAction(
  //         isDestructiveAction: true,
  //         child: const Text('Delete'),
  //         onPressed: () {
  //           Navigator.of(context).pop();
  //         },
  //       ),
  //     ],
  //     enableHapticFeedback: true,
  //     child:
  //   );
  // }

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
