import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timing/src/controller/TimeEntryController.dart';
import 'package:timing/src/view/macros/BottomSheetTemplate.dart';
import 'package:timing/src/view/macros/ContextManager.dart';
import 'package:timing/src/view/pages/home/Add/Overtime.dart';

enum WorkDayType {
  workday,
  vacation,
  sickday,
  overtime,
}

class WorkDay {
  WorkDayType type;
  int minutes;
  DateTime date;

  WorkDay({required this.date, required this.type, required this.minutes});

  Duration getDuration() {
    return Duration(minutes: minutes);
  }

  Map<String, dynamic> toMap() {
    return {
      'minutes': getDuration().inMinutes,
      'type': type.index,
      'date': date.toIso8601String(),
    };
  }

  Widget getWidget(context) {
    return GestureDetector(
      onTap: () {
        showCupertinoModalPopup(useRootNavigator: true, context: context, builder: (context) => BottomSheetEntryForm(child: EntryOvertimePage(workDay: this)));
      },
      onLongPress: () => ContextManager.showDeletePopup(context, () => Provider.of<TimeTrackingController>(context, listen: false).deleteWorkDay(this)),
      child: Container(
          margin: const EdgeInsets.fromLTRB(6, 6, 0, 0),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(border: Border.all(color: const Color.fromARGB(107, 242, 242, 247)), borderRadius: BorderRadius.circular(10), color: const Color.fromARGB(72, 216, 216, 225)),
          child: Row(
            children: [
              minutes > 0
                  ? const Icon(
                      CupertinoIcons.timelapse,
                      size: 20,
                    )
                  : const Icon(
                      CupertinoIcons.timelapse,
                      size: 20,
                      color: CupertinoColors.systemRed,
                    ),
              const SizedBox(width: 8),
              Text(minutes > 0 ? "${(minutes / 60).toStringAsFixed(2)} h" : "${((minutes * -1) / 60).toStringAsFixed(2)} h",
                  style: const CupertinoTextThemeData().textStyle.copyWith(fontSize: 15, fontWeight: FontWeight.w300)),
            ],
          )),
    );
  }

  factory WorkDay.fromMap(Map<String, dynamic> map) {
    return WorkDay(
      date: DateTime.parse(map['date']),
      type: WorkDayType.values[map['type']],
      minutes: map['minutes'],
    );
  }

  Future<int> save(Database db) async {
    return await db.insert('work_days', toMap());
  }

  Future<void> update(Database db) async {
    await db.update('work_days', toMap(), where: 'date = ?', whereArgs: [date.toIso8601String()]);
  }

  Future<void> delete(Database db) async {
    await db.delete('work_days', where: 'date = ?', whereArgs: [date.toIso8601String()]);
  }

  static Future<List<WorkDay>> getAll(Database db) async {
    List<Map<String, dynamic>> maps = await db.query('work_days');
    return maps.map((map) => WorkDay.fromMap(map)).toList();
  }
}
