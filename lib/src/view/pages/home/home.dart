import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timing/src/controller/TimeEntryController.dart';
import 'package:timing/src/model/Month.dart';
import 'package:timing/src/model/TimeEntry.dart';
import 'package:timing/src/view/macros/BottomSheetTemplate.dart';
import 'package:timing/src/view/macros/ContentView.dart';
import 'package:timing/src/view/pages/home/HoursThisWeek.dart';
import 'package:timing/src/view/pages/home/MonthSelection.dart';
import 'package:timing/src/view/pages/home/QuickAdd/QuickAddEntry.dart';
import 'package:timing/src/view/pages/home/ListEntry/TimeEntriesList.dart';
import 'package:timing/src/view/pages/home/TotalOvertime.dart';
import 'package:timing/src/view/pages/FormPage.dart';

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

  Future<void> _initializeData() async {
    final timeTrackingController = Provider.of<TimeTrackingController>(context, listen: false);
    await timeTrackingController.loadEntries();

    if (timeTrackingController.entries.isEmpty) {
      await timeTrackingController.createSampleEntries();
      await timeTrackingController.loadEntries();
    }
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
                          onPressed: () => showCupertinoModalPopup(
                            useRootNavigator: true,
                            context: context,
                            builder: (context) => BottomSheetEntryForm(child: EntryFormPage()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TimeEntriesListWidget(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: QuickAddEntryWidget(),
    );
  }
}
