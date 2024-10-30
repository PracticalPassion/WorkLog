import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:work_log/src/controller/TimeEntryController.dart';
import 'package:work_log/src/controller/purchase.dart';
import 'package:work_log/src/controller/purchase/purchase.dart';
import 'package:work_log/src/controller/settingsController.dart';
import 'package:work_log/src/model/Month.dart';
import 'package:work_log/src/model/TimeEntry.dart';
import 'package:work_log/src/view/macros/BottomSheetTemplate.dart';
import 'package:work_log/src/view/macros/ContentView.dart';
import 'package:work_log/src/view/macros/Snackbar.dart';
import 'package:work_log/src/view/pages/home/Add/FormPopUp.dart';
import 'package:work_log/src/view/pages/home/HoursThisWeek.dart';
import 'package:work_log/src/view/pages/home/MonthSelection.dart';
import 'package:work_log/src/view/pages/home/ListEntry/TimeEntriesList.dart';
import 'package:work_log/src/view/pages/home/QuickAdd/QuickAddEntryColored.dart';
import 'package:work_log/src/view/pages/home/TotalOvertime.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:work_log/src/view/pages/settings/settings.dart';

class TimeTrackingListPage extends StatefulWidget {
  const TimeTrackingListPage({super.key});

  @override
  _TimeTrackingListPageState createState() => _TimeTrackingListPageState();
}

class _TimeTrackingListPageState extends State<TimeTrackingListPage> {
  bool loading = true;
  final CupertinoSnackBar _snackBar = CupertinoSnackBar();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final timeTrackingController = Provider.of<TimeTrackingController>(context, listen: false);
    final settingController = Provider.of<SettingsController>(context, listen: false);
    await settingController.loadUserSettings();
    await timeTrackingController.loadEntries();
    await PurchaseApi.initPlatformState();
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final timeTrackingController = Provider.of<TimeTrackingController>(context);
    final purchaseController = Provider.of<PurchaseController>(context);

    final weeklyHours = TimeTrackingEntry.calculateWeeklyHours(timeTrackingController.entries);

    List<Month> months = TimeTrackingEntry.getMonthsOfYear(DateTime.now().year);

    return loading
        ? const CupertinoPageScaffold(child: CupertinoActivityIndicator())
        : Scaffold(
            backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(width: 20),
                      const Spacer(),
                      GestureDetector(
                          child: Container(padding: const EdgeInsets.all(10), child: const Icon(CupertinoIcons.settings)),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MainViewSettings()));
                          })
                    ],
                  ),
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
                                  if (!purchaseController.access(context)) {
                                    return;
                                  }

                                  if (timeTrackingController.lastStartTime == null) {
                                    showCupertinoModalPopup(
                                      useRootNavigator: true,
                                      context: context,
                                      builder: (context) => const BottomSheetWidget(child: FormPopUp()),
                                    );
                                    return;
                                  }
                                  _snackBar.show(context, AppLocalizations.of(context)!.isRunningInfo);
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
            floatingActionButton: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: CupertinoTheme.of(context).primaryColor,
                  boxShadow: [BoxShadow(color: CupertinoColors.black.withOpacity(0.45), blurRadius: 12, offset: const Offset(0, 0))],
                ),
                child: QuickAddEntryWidgetColored()),
          );
  }
}
