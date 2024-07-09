import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_log/src/controller/settingsController.dart';
import 'package:work_log/src/model/Month.dart';
import 'package:work_log/src/model/TimeEntry.dart';
import 'package:work_log/src/model/UserSettings.dart';
import 'package:work_log/src/model/WorkDay.dart';
import 'package:work_log/src/model/database/database.dart';
import 'package:work_log/src/view/Helper/Extentions/DateTimeExtention.dart';

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

    UserSettings? settings = await SettingsHelper.getUserSettings();
    List<TimeEntry> timeEntries = await TimeEntry.getAll(db);
    List<WorkDay> workDays = await WorkDay.getAll(db);

    _entries = _mapTimeEntriesToTrackingEntries(timeEntries, workDays, settings!);

    totalOvertime = _calculateTotalOvertime(_entries);
    _updateMonthlyOvertime();
    notifyListeners();
  }

  List<TimeTrackingEntry> _mapTimeEntriesToTrackingEntries(List<TimeEntry> timeEntries, List<WorkDay> workDays, UserSettings _settings) {
    Map<DateTime, List<TimeEntry>> groupedEntries = {};

    for (var entry in workDays) {
      DateTime date = DateTime(entry.date.year, entry.date.month, entry.date.day);
      if (!groupedEntries.containsKey(date)) {
        groupedEntries[date] = [];
      }
    }

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

    List<TimeTrackingEntry> futureEntries = groupedEntries.entries.map((e) {
      WorkDay? result = workDays.cast<WorkDay?>().firstWhere(
            (wd) => wd?.date.day == e.key.day && wd?.date.month == e.key.month && wd?.date.year == e.key.year,
            orElse: () => null,
          );
      return TimeTrackingEntry(date: e.key, timeEntries: e.value, expectedWorkHours: _settings.getExpectedWorkHours(e.key), workDay: result);
    }).toList();

    // Warte auf die Erstellung aller TimeTrackingEntry-Objekte
    return futureEntries;
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

  bool startTimeOverlaps(DateTime start, TimeEntry? except) {
    for (var entry in _entries) {
      for (var timeEntry in entry.timeEntries) {
        if (except != null && timeEntry.id == except.id) {
          continue;
        }
        if (start.isBefore(timeEntry.end)) {
          return true;
        }
      }
    }
    return false;
  }

  bool hasEntryOnDate(DateTime? date, TimeEntry? except) {
    if (date == null) {
      return false;
    }
    for (var entry in _entries) {
      for (var timeEntry in entry.timeEntries) {
        if (except != null && timeEntry.id == except.id) {
          continue;
        }
        if (timeEntry.start.toDay() == date.toDay() || timeEntry.end.toDay() == date.toDay()) {
          return true;
        }
      }
    }
    return false;
  }

  bool requestEntryOverlaps(TimeEntryTemplate other, TimeEntry? except) {
    for (var entry in _entries) {
      for (var timeEntry in entry.timeEntries) {
        if (except != null && timeEntry.id == except.id) {
          continue;
        }
        if (timeEntry.start.isBefore(other.end) && timeEntry.end.isAfter(other.start)) {
          return true;
        }
      }
    }
    return false;
  }

  Future<void> onUserSaveTimeEntry() async {}

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

  Future<TimeEntry> getEntry(int id) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    return await TimeEntry.get(db, id);
  }

  Future<void> deleteEntry(TimeEntry entry) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    await entry.delete(db);
    await loadEntries();
  }

  Future<void> saveWorkDay(WorkDay workDay) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    await workDay.save(db);
    await loadEntries();
  }

  Future<void> updateWorkDay(WorkDay workDay) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    await workDay.update(db);
    await loadEntries();
  }

  Future<void> deleteWorkDay(WorkDay workday) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    await workday.delete(db);
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
      final duration = ((workDuration.inMinutes < 0 ? 0 : workDuration.inMinutes) - (entry.expectedWorkHours.inMinutes)) / 60;
      totalOvertime += duration;
    }
    return totalOvertime;
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

  String? stopCurrentEntry(DateTime time, SettingsController settingsController, Duration pause) {
    assert(_lastStartTime != null);
    if (_lastStartTime == null) {
      return 'No start time found';
    }

    if (time.isBefore(_lastStartTime!)) {
      return 'End time is before start time';
    }

    final entry = TimeEntryTemplate(start: _lastStartTime!, end: time, pause: pause);
    saveEntryTemplate(entry);
    removeCurrentStartTime();
    return null;
  }

  bool validateOvertime(TimeEntryTemplate timeEntry) {
    for (var entry in _entries) {
      if (entry.workDay != null) {
        if (entry.workDay!.minutes < 0) {
          if (timeEntry.start.toDay() == entry.date.toDay() || timeEntry.end.toDay() == entry.date.toDay()) {
            return false;
          }
        }
      }
    }
    return true;
  }
}
