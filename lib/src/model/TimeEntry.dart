import 'dart:math';

import 'package:sqflite/sqflite.dart';
import 'package:work_log/src/controller/settingsController.dart';
import 'package:work_log/src/model/Month.dart';
import 'package:work_log/src/model/WorkDay.dart';
import 'package:work_log/src/model/database/database.dart';

class TimeEntryTemplate {
  DateTime start;
  DateTime end;
  Duration? pause;

  TimeEntryTemplate({
    required this.start,
    required this.end,
    this.pause,
  });

  Future<int> save(Database db) async {
    return await db.insert('time_entries', toMap());
  }

  Map<String, dynamic> toMap() {
    return {
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'pause': pause?.inMinutes ?? 0,
    };
  }

  static int calculateDesiredBreak(DateTime start, DateTime end, SettingsController settingsController) {
    final workDuration = end.difference(start);
    final workedMinutes = workDuration.inMinutes;

    if (workedMinutes >= (settingsController.settings!.breakAfterHours.inMinutes)) {
      return min(settingsController.settings!.breakDurationMinutes, workedMinutes - (settingsController.settings!.breakAfterHours.inMinutes));
    }

    return 0;
  }
}

class TimeEntry {
  int id;
  DateTime start;
  DateTime end;
  Duration? pause;

  TimeEntry({
    required this.id,
    required this.start,
    required this.end,
    this.pause,
  });

  Duration get duration => end.difference(start) - (pause ?? Duration.zero);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'pause': pause?.inMinutes ?? 0,
    };
  }

  factory TimeEntry.fromMap(Map<String, dynamic> map) {
    return TimeEntry(
      id: map['id'],
      start: DateTime.parse(map['start']),
      end: DateTime.parse(map['end']),
      pause: Duration(minutes: map['pause']),
    );
  }

  static Future<int> saveEntry(TimeEntry entry) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    var id = await entry.save(db);
    return id;
  }

  Future<int> save(Database db) async {
    return await db.insert('time_entries', toMap());
  }

  Future<void> update(Database db) async {
    await db.update('time_entries', toMap(), where: 'id = ?', whereArgs: [id]);
  }

  Future<void> delete(Database db) async {
    await db.delete('time_entries', where: 'id = ?', whereArgs: [id]);
  }

  static Future<TimeEntry> get(Database db, int id) async {
    List<Map<String, dynamic>> maps = await db.query('time_entries', where: 'id = ?', whereArgs: [id]);
    return TimeEntry.fromMap(maps.first);
  }

  static Future<List<TimeEntry>> getAll(Database db) async {
    List<Map<String, dynamic>> maps = await db.query('time_entries');
    return maps.map((map) => TimeEntry.fromMap(map)).toList();
  }
}

// todo: dont add Time When on Vacation
// todo: when Overtime, display Overtime duration in ListEntry

class TimeTrackingEntry {
  DateTime date;
  Duration expectedWorkHours;
  String description;
  WorkDay? workDay;
  List<TimeEntry> timeEntries;

  TimeTrackingEntry({required this.date, this.description = '', required this.timeEntries, required this.expectedWorkHours, this.workDay});

  Duration get netDuration {
    Duration dur = timeEntries.fold(Duration.zero, (total, entry) => total + entry.duration);
    dur = dur + (workDay?.getDuration() ?? Duration.zero);

    if (workDay != null && workDay!.minutes < 0) {
      assert(timeEntries.length == 0);
      dur = Duration(minutes: workDay!.minutes);
    }

    return dur;
  }

  // 3. Über Nacht Einträge aufteilen
  void splitOvernightEntries() {
    List<TimeEntry> splitEntries = [];

    for (var entry in timeEntries) {
      if (entry.start.day != entry.end.day) {
        // Start Tag
        splitEntries.add(TimeEntry(
          id: entry.id,
          start: entry.start,
          end: DateTime(entry.start.year, entry.start.month, entry.start.day, 23, 59, 59),
        ));
        // End Tag
        splitEntries.add(TimeEntry(
          id: entry.id,
          start: DateTime(entry.end.year, entry.end.month, entry.end.day, 0, 0, 0),
          end: entry.end,
        ));
      } else {
        splitEntries.add(entry);
      }
    }

    timeEntries = splitEntries;
  }

  // 4. Hinzufügen eines TimeEntry
  void addTimeEntry(TimeEntry newEntry) {
    timeEntries.add(newEntry);
    timeEntries.sort((a, b) => a.start.compareTo(b.start)); // Sortieren nach Startzeit
  }

  // Methoden für Berechnungen und Datenverarbeitung bleiben wie zuvor

  static double calculateTotalOvertime(List<TimeTrackingEntry> entries) {
    double totalOvertime = 0.0;
    for (var entry in entries) {
      final workDuration = entry.netDuration;
      final workHours = workDuration.inHours;
      final workMinutes = workDuration.inMinutes % 60;
      final difference = workHours + workMinutes / 60 - (entry.expectedWorkHours.inMinutes * 60);
      totalOvertime += difference;
    }
    return totalOvertime;
  }

  static double calculateTotalOvertimeMonth(List<TimeTrackingEntry> entries) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);

    double totalOvertime = 0.0;
    for (var entry in entries) {
      if (entry.timeEntries.any((te) => te.start.isAfter(monthStart) && te.start.isBefore(monthEnd))) {
        final workDuration = entry.netDuration;
        final workHours = workDuration.inHours;
        final workMinutes = workDuration.inMinutes % 60;
        final difference = workHours + workMinutes / 60 - (entry.expectedWorkHours.inMinutes * 60);
        totalOvertime += difference;
      }
    }
    return totalOvertime;
  }

  static double calculateWeeklyHours(List<TimeTrackingEntry> entries) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = now.add(Duration(days: DateTime.daysPerWeek - now.weekday));

    double weeklyHours = 0.0;
    for (var entry in entries) {
      if (entry.timeEntries.any((te) => te.start.isAfter(weekStart) && te.start.isBefore(weekEnd))) {
        final workDuration = entry.netDuration;
        final workHours = workDuration.inHours;
        final workMinutes = workDuration.inMinutes % 60;
        weeklyHours += workHours + workMinutes / 60;
      }
    }
    return weeklyHours;
  }

  static List<DateTime> getDaysInMonth(Month month) {
    final now = DateTime.now();
    List<DateTime> days = [];
    DateTime date = DateTime(month.year, month.month, 1);
    while (date.month == month.month && date.isBefore(now)) {
      days.add(date);
      date = date.add(const Duration(days: 1));
    }
    days.sort((a, b) => b.compareTo(a));
    return days;
  }

  static List<DateTime> getDaysInYear(int year) {
    List<DateTime> days = [];
    DateTime date = DateTime(year, 1, 1);
    final now = DateTime.now();
    while (date.year == year && date.isBefore(now)) {
      days.add(date);
      date = date.add(const Duration(days: 1));
    }
    days.sort((a, b) => b.compareTo(a));
    return days;
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  static List<Month> getMonthsOfYear(int year) {
    List<Month> months = [];
    for (int i = 1; i <= 12; i++) {
      if (DateTime(year, i).isAfter(DateTime.now())) {
        break;
      }
      months.add(Month(year, i));
    }
    // months.sort((a, b) => b.month.compareTo(a.month));
    return months;
  }
}
