import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:timing/src/model/Break.dart';
import 'package:timing/src/model/Month.dart';
import 'package:timing/src/model/TimeEntry.dart';
import 'package:timing/src/model/database/database.dart';
import 'package:timing/src/model/database/timeEntry.dart';

class TimeTrackingController extends ChangeNotifier {
  List<TimeTrackingEntry> _entries = [];

  List<TimeTrackingEntry> get entries => _entries;

  double _totalOvertime = 0.0;
  double get totalOvertime => _totalOvertime;
  set totalOvertime(double value) {
    _totalOvertime = value;
    notifyListeners();
  }

  double _totalOvertimeMonth = 0.0;
  double get totalOvertimeMonth => _totalOvertimeMonth;
  set totalOvertimeMonth(double value) {
    _totalOvertimeMonth = value;
    notifyListeners();
  }

  Month _currentMonth = Month(DateTime.now().year, DateTime.now().month);
  Month get currentMonth => _currentMonth;
  set currentMonth(Month month) {
    _currentMonth = month;
    totalOvertimeMonth = TimeTrackingEntry.calculateTotalOvertime(_entries.where((e) => e.start.year == month.year && e.start.month == month.month).toList());
    notifyListeners();
  }

  Future<void> loadEntries() async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    _entries = await TimeTrackingEntryExtension.getAll(db);

    if (_entries.isEmpty) {
      await createSampleEntries();
    }
    totalOvertime = TimeTrackingEntry.calculateTotalOvertime(_entries);
    totalOvertimeMonth = TimeTrackingEntry.calculateTotalOvertime(_entries.where((e) => e.start.year == currentMonth.year && e.start.month == currentMonth.month).toList());
    notifyListeners();
  }

  Future<void> saveEntry(TimeTrackingEntry entry) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    if (entry.id == null) {
      entry.id = await db.insert('time_tracking_entries', entry.toMap());
    } else {
      await db.update('time_tracking_entries', entry.toMap(), where: 'id = ?', whereArgs: [entry.id]);
    }

    for (var b in entry.breaks) {
      b.entryId = entry.id!;
      if (b.id == null) {
        b.id = await db.insert('breaks', b.toMap());
      } else {
        await db.update('breaks', b.toMap(), where: 'id = ?', whereArgs: [b.id]);
      }
    }
    await loadEntries();
  }

  Future<void> deleteEntry(int id) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    await db.delete('time_tracking_entries', where: 'id = ?', whereArgs: [id]);
    await db.delete('breaks', where: 'entryId = ?', whereArgs: [id]);
    await loadEntries();
  }

  Future<void> createSampleEntries() async {
    List<TimeTrackingEntry> sampleEntries = [
      TimeTrackingEntry(
        start: DateTime.now().subtract(Duration(days: 1, hours: 10)),
        end: DateTime.now().subtract(Duration(days: 1)),
        expected_work_hours: 7.5,
        description: 'Worked on Project A',
        breaks: [
          Break(
            entryId: 0,
            start: DateTime.now().subtract(Duration(days: 1, hours: 4, minutes: 30)),
            end: DateTime.now().subtract(Duration(days: 1, hours: 4)),
          ),
        ],
      ),
      TimeTrackingEntry(
        start: DateTime.now().subtract(Duration(days: 2, hours: 9)),
        end: DateTime.now().subtract(Duration(days: 2, hours: 1)),
        expected_work_hours: 7,
        description: 'Worked on Project B',
        breaks: [
          Break(
            entryId: 1,
            start: DateTime.now().subtract(Duration(days: 2, hours: 5, minutes: 30)),
            end: DateTime.now().subtract(Duration(days: 2, hours: 5)),
          ),
        ],
      ),
    ];

    for (var entry in sampleEntries) {
      await saveEntry(entry);
    }
  }
}
