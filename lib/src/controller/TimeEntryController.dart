import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timing/src/model/Month.dart';
import 'package:timing/src/model/TimeEntry.dart';
import 'package:timing/src/model/database/database.dart';

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

  DateTime? _lastStartTime;
  DateTime? get lastStartTime => _lastStartTime;

  Future<void> loadEntries() async {
    await getCurrentStartTime();
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    List<TimeEntry> timeEntries = await TimeEntry.getAll(db);
    _entries = _mapTimeEntriesToTrackingEntries(timeEntries);

    totalOvertime = _calculateTotalOvertime(_entries);
    _updateMonthlyOvertime();
    notifyListeners();
  }

  List<TimeTrackingEntry> _mapTimeEntriesToTrackingEntries(List<TimeEntry> timeEntries) {
    Map<DateTime, List<TimeEntry>> groupedEntries = {};

    for (var entry in timeEntries) {
      DateTime date = DateTime(entry.start.year, entry.start.month, entry.start.day);
      if (!groupedEntries.containsKey(date)) {
        groupedEntries[date] = [];
      }
      groupedEntries[date]!.add(entry);

      // Über Mitternacht hinausgehende Einträge
      if (entry.start.day != entry.end.day) {
        _splitOvernightEntry(entry, groupedEntries);
      }
    }

    return groupedEntries.entries.map((e) {
      return TimeTrackingEntry(
        date: e.key,
        timeEntries: e.value,
      );
    }).toList();
  }

  void _splitOvernightEntry(TimeEntry entry, Map<DateTime, List<TimeEntry>> groupedEntries) {
    DateTime midnight = DateTime(entry.start.year, entry.start.month, entry.start.day).add(const Duration(days: 1));
    TimeEntry beforeMidnight = TimeEntry(
      id: entry.id,
      start: entry.start,
      end: midnight,
    );
    TimeEntry afterMidnight = TimeEntry(
      id: entry.id,
      start: midnight,
      end: entry.end,
    );

    groupedEntries[DateTime(entry.start.year, entry.start.month, entry.start.day)]!.remove(entry);
    groupedEntries[DateTime(entry.start.year, entry.start.month, entry.start.day)]!.add(beforeMidnight);

    DateTime nextDay = DateTime(afterMidnight.start.year, afterMidnight.start.month, afterMidnight.start.day);
    if (!groupedEntries.containsKey(nextDay)) {
      groupedEntries[nextDay] = [];
    }
    groupedEntries[nextDay]!.add(afterMidnight);

    // Wiederholung, falls weiter über Nacht
    if (afterMidnight.start.day != afterMidnight.end.day) {
      _splitOvernightEntry(afterMidnight, groupedEntries);
    }
  }

  bool requestEntryOverlaps(TimeEntryTemplate other) {
    for (var entry in _entries) {
      for (var timeEntry in entry.timeEntries) {
        if (timeEntry.start.isBefore(other.end) && timeEntry.end.isAfter(other.start)) {
          return true;
        }
      }
    }
    return false;
  }

  bool requestEntryOverlapsExcept(TimeEntryTemplate other, TimeEntry except) {
    for (var entry in _entries) {
      for (var timeEntry in entry.timeEntries) {
        if (timeEntry.id == except.id) {
          continue;
        }
        if (timeEntry.start.isBefore(other.end) && timeEntry.end.isAfter(other.start)) {
          return true;
        }
      }
    }
    return false;
  }

  Future<void> saveEntryTemplate(TimeEntryTemplate entry) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    await entry.save(db);
    await loadEntries();
  }

  Future<void> saveEntry(TimeEntry entry) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    await entry.save(db);
    await loadEntries();
  }

  Future<void> updateEntry(TimeEntry entry) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    await entry.update(db);
    await loadEntries();
  }

  Future<void> deleteEntry(int id) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    await db.delete('time_entries', where: 'id = ?', whereArgs: [id]);
    await loadEntries();
  }

  void _updateMonthlyOvertime() {
    totalOvertimeMonth = _calculateTotalOvertime(
      _entries.where((e) => e.date.year == currentMonth.year && e.date.month == currentMonth.month).toList(),
    );
  }

  double _calculateTotalOvertime(List<TimeTrackingEntry> entries) {
    double totalOvertime = 0.0;
    for (var entry in entries) {
      final workDuration = entry.netDuration;
      final workHours = workDuration.inHours;
      final workMinutes = workDuration.inMinutes % 60;
      final difference = workHours + workMinutes / 60 - entry.expectedWorkHours;
      totalOvertime += difference;
    }
    return totalOvertime;
  }

  Future<void> createSampleEntries() async {
    List<TimeEntryTemplate> sampleEntries = [
      TimeEntryTemplate(
        start: DateTime.now().subtract(const Duration(days: 1, hours: 10)),
        end: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
      ),
      TimeEntryTemplate(
        start: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
        end: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      ),
      TimeEntryTemplate(
        start: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        end: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
      ),
      TimeEntryTemplate(
        start: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        end: DateTime.now().subtract(const Duration(days: 0, hours: 0)),
      ),
      TimeEntryTemplate(
        start: DateTime.now().subtract(const Duration(days: 2, hours: 9)),
        end: DateTime.now().subtract(const Duration(days: 2, hours: 7)),
      ),
      TimeEntryTemplate(
        start: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
        end: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
      ),
    ];

    for (var entry in sampleEntries) {
      await saveEntryTemplate(entry);
    }
  }

  Future<bool> hasStartTime() async {
    final prefs = await SharedPreferences.getInstance();
    final startTimeString = prefs.getString('currentStartTime');
    return startTimeString != null;
  }

  Future<void> getCurrentStartTime() async {
    final prefs = await SharedPreferences.getInstance();
    final startTimeString = prefs.getString('currentStartTime');
    if (startTimeString != null) {
      _lastStartTime = DateTime.parse(startTimeString);
      notifyListeners();
    }
  }

  Future<void> removeCurrentStartTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentStartTime');
    _lastStartTime = null;
    notifyListeners();
  }

  Future<void> saveCurrentStartTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentStartTime', time.toIso8601String());

    _lastStartTime = time;
    notifyListeners();
  }

  void stopCurrentEntry(DateTime time) {
    assert(_lastStartTime != null);
    final entry = TimeEntryTemplate(start: _lastStartTime!, end: time);
    saveEntryTemplate(entry);
    removeCurrentStartTime();
  }
}
