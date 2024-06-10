import 'dart:ffi';

import 'package:intl/intl.dart';
import 'package:timing/src/model/Break.dart';
import 'package:timing/src/model/Month.dart';

class TimeEntry {
  DateTime start;
  DateTime end;

  TimeEntry({
    required this.start,
    required this.end,
  });

  Duration get duration => end.difference(start);

  Map<String, dynamic> toMap() {
    return {
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
    };
  }

  factory TimeEntry.fromMap(Map<String, dynamic> map) {
    return TimeEntry(
      start: DateTime.parse(map['start']),
      end: DateTime.parse(map['end']),
    );
  }
}

class TimeTrackingEntry {
  int? id;
  double expectedWorkHours;
  String description;
  List<TimeEntry> timeEntries;

  TimeTrackingEntry({
    this.id,
    required this.expectedWorkHours,
    required this.description,
    required List<TimeEntry> timeEntries,
  })  : assert(timeEntries.isNotEmpty, 'At least one TimeEntry must be provided.'),
        this.timeEntries = timeEntries;

  Duration get netDuration => timeEntries.fold(const Duration(), (total, t) => total + t.duration);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'expected_work_hours': expectedWorkHours,
      'description': description,
      'time_entries': timeEntries.map((e) => e.toMap()).toList(),
    };
  }

  factory TimeTrackingEntry.fromMap(Map<String, dynamic> map) {
    return TimeTrackingEntry(
      id: map['id'],
      expectedWorkHours: map['expected_work_hours'],
      description: map['description'],
      timeEntries: (map['time_entries'] as List).map((e) => TimeEntry.fromMap(e)).toList(),
    );
  }

  // 1. Erster Start-Eintrag
  TimeEntry get firstStartEntry {
    return timeEntries.reduce((a, b) => a.start.isBefore(b.start) ? a : b);
  }

  // 2. Letzter Start-Eintrag
  TimeEntry get lastStartEntry {
    return timeEntries.reduce((a, b) => a.start.isAfter(b.start) ? a : b);
  }

  // 3. Über Nacht Einträge aufteilen
  void splitOvernightEntries() {
    List<TimeEntry> splitEntries = [];

    for (var entry in timeEntries) {
      if (entry.start.day != entry.end.day) {
        // Start Tag
        splitEntries.add(TimeEntry(
          start: entry.start,
          end: DateTime(entry.start.year, entry.start.month, entry.start.day, 23, 59, 59),
        ));
        // End Tag
        splitEntries.add(TimeEntry(
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
      final difference = workHours + workMinutes / 60 - entry.expectedWorkHours;
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
        final difference = workHours + workMinutes / 60 - entry.expectedWorkHours;
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
      date = date.add(Duration(days: 1));
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
      date = date.add(Duration(days: 1));
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
