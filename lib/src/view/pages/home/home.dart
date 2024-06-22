import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timing/src/controller/TimeEntryController.dart';
import 'package:timing/src/controller/settingsController.dart';
import 'package:timing/src/model/Month.dart';
import 'package:timing/src/model/TimeEntry.dart';
import 'package:timing/src/model/WorkDay.dart';
import 'package:timing/src/model/database/database.dart';
import 'package:timing/src/view/macros/BottomSheetTemplate.dart';
import 'package:timing/src/view/macros/ContentView.dart';
import 'package:timing/src/view/pages/home/Add/FormPopUp.dart';
import 'package:timing/src/view/pages/home/HoursThisWeek.dart';
import 'package:timing/src/view/pages/home/MonthSelection.dart';
import 'package:timing/src/view/pages/home/ListEntry/TimeEntriesList.dart';
import 'package:timing/src/view/pages/home/QuickAdd/QuickAddEntryColored.dart';
import 'package:timing/src/view/pages/home/TotalOvertime.dart';

class TimeTrackingListPage extends StatefulWidget {
  @override
  _TimeTrackingListPageState createState() => _TimeTrackingListPageState();
}

class _TimeTrackingListPageState extends State<TimeTrackingListPage> {
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  OverlayEntry? _overlayEntry;

  void _showCupertinoSnackBar(String message) {
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50.0,
        left: MediaQuery.of(context).size.width * 0.1,
        width: MediaQuery.of(context).size.width * 0.8,
        child: CupertinoPopupSurface(
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              message,
              style: TextStyle(color: CupertinoColors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    Future.delayed(const Duration(seconds: 3), () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  Future<void> _initializeData() async {
    final timeTrackingController = Provider.of<TimeTrackingController>(context, listen: false);
    final settingController = Provider.of<SettingsController>(context, listen: false);
    await timeTrackingController.loadEntries();

    // if (timeTrackingController.entries.isEmpty) {
    //   var db = await DatabaseHelper().database;

    //   await WorkDay(
    //     date: DateTime.now(),
    //     type: WorkDayType.overtime,
    //     minutes: 420,
    //   ).save(db);
    //   await WorkDay(
    //     date: DateTime.now().subtract(Duration(days: 3)),
    //     type: WorkDayType.overtime,
    //     minutes: -480,
    //   ).save(db);

    //   await timeTrackingController.createSampleEntries(settingController);
    //   await timeTrackingController.loadEntries();
    // }
  }

  @override
  Widget build(BuildContext context) {
    final timeTrackingController = Provider.of<TimeTrackingController>(context);
    final weeklyHours = TimeTrackingEntry.calculateWeeklyHours(timeTrackingController.entries);

    List<Month> months = TimeTrackingEntry.getMonthsOfYear(DateTime.now().year);

    return Scaffold(
      backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: TotalOvertimeWidget(totalOvertime: timeTrackingController.totalOvertime)),
                Expanded(child: HoursThisWeekWidget(weeklyHours: weeklyHours)),
              ],
            ),
            Expanded(
              child: ContentView(
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: MonthSelectionWidget(
                            months: months.map((month) => month.getName(Localizations.localeOf(context))).toList(),
                            selectedIndex: months.indexWhere((month) => month.isSameMonth(timeTrackingController.currentMonth)),
                            onSelect: (index) {
                              setState(() {
                                timeTrackingController.currentMonth = months[index];
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        CupertinoButton(
                          child: const Icon(CupertinoIcons.add),
                          onPressed: () {
                            if (timeTrackingController.lastStartTime == null) {
                              showCupertinoModalPopup(
                                useRootNavigator: true,
                                context: context,
                                builder: (context) => BottomSheetEntryForm(child: FormPopUp()),
                              );
                              return;
                            }
                            _showCupertinoSnackBar('One entry is already running. Please stop it first.');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const TimeEntriesListWidget(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: QuickAddEntryWidgetColored(),
    );
  }
}
