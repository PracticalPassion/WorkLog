import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:work_log/src/controller/TimeEntryController.dart';
import 'package:work_log/src/controller/purchase.dart';
import 'package:work_log/src/controller/settingsController.dart';
import 'package:work_log/src/model/TimeEntry.dart';
import 'package:work_log/src/view/Helper/Extentions/DateTimeExtention.dart';
import 'package:work_log/src/view/Helper/Extentions/DurationExtention.dart';
import 'package:work_log/src/view/macros/BottomSheetTemplate.dart';
import 'package:work_log/src/view/macros/ContextManager.dart';
import 'package:work_log/src/view/macros/Snackbar.dart';
import 'package:work_log/src/view/pages/home/Add/FormPage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:work_log/src/view/pages/home/Add/FormPopUp.dart';

class EntryTile extends StatefulWidget {
  final TimeTrackingEntry entry;
  EntryTile({required this.entry});

  @override
  State<EntryTile> createState() => _EntryTileState();
}

class _EntryTileState extends State<EntryTile> {
  final CupertinoSnackBar _snackBar = CupertinoSnackBar();
  @override
  Widget build(BuildContext context) {
    final purchaseController = Provider.of<PurchaseController>(context);
    var textFontSize = CupertinoTheme.of(context).textTheme.textStyle.fontSize ?? 14;
    textFontSize = textFontSize - 1;

    final settingsController = Provider.of<SettingsController>(context);
    final timeTrackingController = Provider.of<TimeTrackingController>(context);

    final Duration workDuration = widget.entry.netDuration;
    final Duration dura = (settingsController.settings!.dailyWorkingHours[widget.entry.date.weekday]!);
    final Duration difference = Duration(minutes: (widget.entry.netDuration.inMinutes < 0 ? 0 : widget.entry.netDuration.inMinutes) - dura.inMinutes);
    final DateTime date = widget.entry.date;

    List<TimeEntry> sortedEntries = List.from(widget.entry.timeEntries)..sort((a, b) => a.start.compareTo(b.start));

    return GestureDetector(
      onTap: () {
        if (!purchaseController.access(context)) {
          return;
        }

        // WidgetsBinding.instance.addPostFrameCallback((_) {
        if (timeTrackingController.lastStartTime != null) {
          _snackBar.show(context, AppLocalizations.of(context)!.isRunningInfo);
          return;
        }

        if (widget.entry.workDay == null && widget.entry.timeEntries.isEmpty) {
          final DateTime startDate = widget.entry.date.copyWith(hour: 8);
          final DateTime endDate =
              widget.entry.date.copyWith(minute: startDate.hour * 60 + settingsController.getExpectedWorkHours(widget.entry.date).inMinutes + settingsController.settings!.breakDurationMinutes);

          showCupertinoModalPopup(
              useRootNavigator: true,
              context: context,
              builder: (context) => BottomSheetWidget(
                      child: FormPopUp(
                    passedStart: startDate,
                    passedEnd: endDate,
                    // title: AppLocalizations.of(context)!.newEntry,
                  )));
        }
        // }
        // );
      },
      child: Container(
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
                    Text(date.getWeekDayName(Localizations.localeOf(context)),
                        style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                              fontSize: textFontSize,
                              color: settingsController.settings!.dailyWorkingHours[widget.entry.date.weekday]!.inMinutes > 0 ? CupertinoColors.activeBlue : CupertinoTheme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            )),
                    Text(date.dayShortDate(), style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(fontSize: textFontSize)),
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
                        children: sortedEntries.map((timeEntry) {
                          return GestureDetector(
                            onTap: () => showCupertinoModalPopup(useRootNavigator: true, context: context, builder: (context) => BottomSheetWidget(child: EntryFormPage(entry: timeEntry))),
                            // popup to delete or edit
                            onLongPress: () => ContextManager.showDeletePopup(context, () => timeTrackingController.deleteEntry(timeEntry)),

                            child: Container(
                              margin: const EdgeInsets.fromLTRB(6, 6, 0, 0),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                  border: Border.all(color: const Color.fromARGB(107, 242, 242, 247)), borderRadius: BorderRadius.circular(10), color: const Color.fromARGB(72, 216, 216, 225)),
                              child: Row(
                                children: [
                                  Text(
                                    '${timeEntry.start.formatTime2H2M()} - ${timeEntry.end.formatTime2H2M()}',
                                    style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(fontSize: textFontSize, fontWeight: FontWeight.w300),
                                  ),
                                  const SizedBox(width: 15),
                                  if (timeEntry.pause != null && timeEntry.pause!.inMinutes != 0)
                                    Row(
                                      children: [
                                        const Icon(CupertinoIcons.timer, size: 15),
                                        const SizedBox(width: 5),
                                        Text(timeEntry.pause!.toFractionalHours()),
                                      ],
                                    )
                                ],
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
                width: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(workDuration.inMinutes == 0 ? "" : workDuration.formatDaration1H2M(), style: CupertinoTheme.of(context).textTheme.textStyle),
                    Text(
                      workDuration.inMinutes == 0 ? "" : '${difference.toFractionalHours()} h',
                      style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.copyWith(
                            fontSize: textFontSize - 2,
                            color: difference.inMinutes >= 0 ? CupertinoTheme.of(context).primaryColor : CupertinoColors.systemRed,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
