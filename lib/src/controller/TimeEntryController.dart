import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
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
    _updateMonthlyOvertime();
    notifyListeners();
  }

  Future<void> loadEntries() async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    _entries = await TimeTrackingEntryExtension.getAll(db);

    if (_entries.isEmpty) {
      print('No entries found. Creating sample entries.');
      await createSampleEntries();
    }
    totalOvertime = TimeTrackingEntry.calculateTotalOvertime(_entries);
    _updateMonthlyOvertime();
    notifyListeners();
  }

  Future<void> saveEntry(TimeTrackingEntry entry) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    await entry.save(db);
    await loadEntries();
  }

  Future<void> deleteEntry(int id) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    await db.delete(TimeTrackingEntryExtension.timeEntryTableName, where: 'tracking_entry_id = ?', whereArgs: [id]);
    await db.delete(TimeTrackingEntryExtension.tableName, where: 'id = ?', whereArgs: [id]);
    await loadEntries();
  }

  Future<void> createSampleEntries() async {
    List<TimeTrackingEntry> sampleEntries = [
      TimeTrackingEntry(
        expectedWorkHours: 7.5,
        description: 'Worked on Project A',
        timeEntries: [
          TimeEntry(
            start: DateTime.now().subtract(Duration(days: 1, hours: 10)),
            end: DateTime.now().subtract(Duration(days: 1, hours: 8)),
          ),
          TimeEntry(
            start: DateTime.now().subtract(Duration(days: 1, hours: 6)),
            end: DateTime.now().subtract(Duration(days: 1, hours: 4)),
          ),
          TimeEntry(
            start: DateTime.now().subtract(Duration(days: 1, hours: 2)),
            end: DateTime.now().subtract(Duration(days: 1, hours: 1)),
          ),
          TimeEntry(
            start: DateTime.now().subtract(Duration(days: 1, hours: 2)),
            end: DateTime.now().subtract(Duration(days: 0, hours: 0)),
          ),
        ],
      ),
      TimeTrackingEntry(
        expectedWorkHours: 7.0,
        description: 'Worked on Project B',
        timeEntries: [
          TimeEntry(
            start: DateTime.now().subtract(Duration(days: 2, hours: 9)),
            end: DateTime.now().subtract(Duration(days: 2, hours: 7)),
          ),
          TimeEntry(
            start: DateTime.now().subtract(Duration(days: 2, hours: 5)),
            end: DateTime.now().subtract(Duration(days: 2, hours: 3)),
          ),
        ],
      ),
    ];

    for (var entry in sampleEntries) {
      await saveEntry(entry);
    }
  }

  void _updateMonthlyOvertime() {
    totalOvertimeMonth = TimeTrackingEntry.calculateTotalOvertimeMonth(
      _entries.where((e) => e.timeEntries.any((te) => te.start.year == currentMonth.year && te.start.month == currentMonth.month)).toList(),
    );
  }
}
