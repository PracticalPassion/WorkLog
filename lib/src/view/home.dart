import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timing/src/controller/TimeEntryController.dart';
import 'package:timing/src/controller/settingsController.dart';
import 'package:timing/src/model/Month.dart';
import 'package:timing/src/model/TimeEntry.dart';
import 'package:timing/src/view/macros/CircularTextEidget.dart';
import 'package:timing/src/view/macros/ContentView.dart';
import 'package:timing/src/view/macros/EntryTile.dart';
import 'package:timing/src/view/macros/InfoTile.dart';
import 'package:timing/src/view/macros/MontlyDisplay.dart';
import 'package:timing/src/view/macros/VertivalSelection.dart';

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

  DateTime? _currentStartTime;
  String? _currentEntryDescription;

  Future<void> _initializeData() async {
    final timeTrackingController = Provider.of<TimeTrackingController>(context, listen: false);

    await timeTrackingController.loadEntries();

    if (timeTrackingController.entries.isEmpty) {
      await timeTrackingController.createSampleEntries();
      await timeTrackingController.loadEntries();
    }
  }

  Future<void> _loadCurrentStartTime() async {
    final prefs = await SharedPreferences.getInstance();
    final startTimeString = prefs.getString('currentStartTime');
    final description = prefs.getString('currentEntryDescription');
    if (startTimeString != null) {
      setState(() {
        _currentStartTime = DateTime.parse(startTimeString);
        _currentEntryDescription = description ?? '';
      });
    }
  }

  Future<void> _saveCurrentStartTime(DateTime? startTime, String? description) async {
    final prefs = await SharedPreferences.getInstance();
    if (startTime != null) {
      await prefs.setString('currentStartTime', startTime.toIso8601String());
      await prefs.setString('currentEntryDescription', description ?? '');
    } else {
      await prefs.remove('currentStartTime');
      await prefs.remove('currentEntryDescription');
    }
  }

  void _showDescriptionDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        String description = '';
        return CupertinoAlertDialog(
          title: Text('Start Time Tracking'),
          content: Column(
            children: [
              CupertinoTextField(
                placeholder: 'Description',
                onChanged: (value) {
                  description = value;
                },
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text('Start'),
              onPressed: () {
                setState(() {
                  _currentStartTime = DateTime.now();
                  _currentEntryDescription = description;
                  _saveCurrentStartTime(_currentStartTime, _currentEntryDescription);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _stopCurrentEntry(BuildContext context) {
    final timeTrackingController = Provider.of<TimeTrackingController>(context, listen: false);
    final entry = TimeTrackingEntry(
      start: _currentStartTime!,
      end: DateTime.now(),
      expected_work_hours: 8,
      description: _currentEntryDescription ?? 'No description',
    );
    timeTrackingController.saveEntry(entry);
    setState(() {
      _currentStartTime = null;
      _currentEntryDescription = null;
      _saveCurrentStartTime(null, null);
    });
  }

  // state changes

  @override
  Widget build(BuildContext context) {
    final timeTrackingController = Provider.of<TimeTrackingController>(context);
    final settingsController = Provider.of<SettingsController>(context);

    final weeklyHours = TimeTrackingEntry.calculateWeeklyHours(timeTrackingController.entries);
    final daysMonth = TimeTrackingEntry.getDaysInMonth(timeTrackingController.currentMonth);

    List<Month> months = TimeTrackingEntry.getMonthsOfYear(DateTime.now().year);

    return Scaffold(
      // backgroundColor: const Color.fromARGB(255, 143, 165, 156),
      backgroundColor: Color.fromARGB(255, 193, 215, 199),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              child: Row(
                children: [
                  Expanded(
                      child: ContentView(
                    margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    padding: const EdgeInsets.all(10),
                    child: InfoTile(
                      title: 'Total Overtime',
                      value: '${timeTrackingController.totalOvertime.toStringAsFixed(2)} h',
                    ),
                  )),
                  Expanded(
                      child: ContentView(
                    margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    padding: const EdgeInsets.all(10),
                    child: InfoTile(
                      title: 'Hours this Week',
                      value: '${weeklyHours.toStringAsFixed(2)} h',
                    ),
                  )),
                ],
              ),
            ),
            // VerticalSelection(
            //     data: months.map((month) => month.name).toList(),
            //     selectedIndex: months.indexWhere((month) => month.isSameMonth(timeTrackingController.currentMonth)),
            //     onSelect: (index) {
            //       setState(() {
            //         timeTrackingController.currentMonth = months[index];
            //       });
            //     }),
            Expanded(
                child: ContentView(
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              // padding: const EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Expanded(
                      child: VerticalSelection(
                          data: months.map((month) => month.name).toList(),
                          selectedIndex: months.indexWhere((month) => month.isSameMonth(timeTrackingController.currentMonth)),
                          onSelect: (index) {
                            setState(() {
                              timeTrackingController.currentMonth = months[index];
                            });
                          }),
                      // MonthDisplay(month: timeTrackingController.currentMonth),
                      // const)
                      // const Spacer(),
                    ),
                    const SizedBox(width: 10),
                    // vertiical divider
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: CupertinoColors.black.withOpacity(0.1),
                            width: 3,
                          ),
                        ),
                      ),
                      margin: const EdgeInsets.all(0),
                      padding: const EdgeInsets.only(left: 5),
                      child: CircularTextWidget(totalOvertimeMonth: timeTrackingController.totalOvertimeMonth),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  Expanded(
                    child: timeTrackingController.entries.isEmpty
                        ? const Center(child: CupertinoActivityIndicator())
                        : CupertinoScrollbar(
                            child: ListView.builder(
                              itemCount: daysMonth.length,
                              itemBuilder: (context, index) {
                                final day = daysMonth[index];
                                final entry = timeTrackingController.entries.firstWhere(
                                  (entry) => TimeTrackingEntry.isSameDay(entry.start, day),
                                  orElse: () => TimeTrackingEntry(
                                    start: day,
                                    end: day.add(const Duration(hours: 0)),
                                    expected_work_hours: 0,
                                    description: '',
                                    breaks: [],
                                  ),
                                );
                                final isZeroHourDay = settingsController.settings?.dailyWorkingHours[DateFormat('EEEE').format(day)] == 0;
                                return EntryTile(
                                  entry: entry,
                                  dailyWorkHours: 0, // Assume 8 hours as daily work hours
                                  isZeroHourDay: isZeroHourDay,
                                );
                              },
                            ),
                          ),
                    // ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
      floatingActionButton: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          if (_currentStartTime == null) {
            _showDescriptionDialog(context);
          } else {
            _stopCurrentEntry(context);
          }
        },
        child: Icon(
          _currentStartTime == null ? CupertinoIcons.play_arrow : CupertinoIcons.stop,
        ),
      ),
    );
  }
}
