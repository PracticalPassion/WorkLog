import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:work_log/src/controller/TimeEntryController.dart';
import 'package:work_log/src/controller/settingsController.dart';
import 'package:work_log/src/model/TimeEntry.dart';
import 'package:work_log/src/view/pages/home/ListEntry/EntryTile.dart';

class TimeEntriesListWidget extends StatelessWidget {
  const TimeEntriesListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsController = Provider.of<SettingsController>(context);
    final timeTrackingController = Provider.of<TimeTrackingController>(context);

    final daysMonth = TimeTrackingEntry.getDaysInMonth(timeTrackingController.currentMonth);

    print('daysMonth: $daysMonth');

    return Expanded(
      child: CupertinoScrollbar(
        child: ListView.builder(
          itemCount: daysMonth.length,
          itemBuilder: (context, index) {
            final day = daysMonth[index];
            final entry = timeTrackingController.entries.firstWhere(
              (entry) => TimeTrackingEntry.isSameDay(entry.date, day),
              orElse: () => TimeTrackingEntry(
                date: day,
                timeEntries: [],
                expectedWorkHours: Duration.zero,
                description: '',
              ),
            );
            // todo: database version for expected work hours
            entry.expectedWorkHours = settingsController.getExpectedWorkHours(day);
            return EntryTile(
              entry: entry,
            );
          },
        ),
      ),
      // ),
    );
  }
}
