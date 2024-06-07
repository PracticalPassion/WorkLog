import 'dart:ffi';

import 'package:intl/intl.dart';
import 'package:timing/src/model/Break.dart';
import 'package:timing/src/model/Month.dart';

class TimeTrackingEntry {
  int? id;
  DateTime start;
  DateTime end;
  double expected_work_hours;
  String description;
  List<Break> breaks;

  TimeTrackingEntry({
    this.id,
    required this.start,
    required this.end,
    required this.expected_work_hours,
    required this.description,
    this.breaks = const [],
  });

  Duration get totalBreakTime => breaks.fold(const Duration(), (total, b) => total + b.duration);

  Duration get netDuration => end.difference(start) - totalBreakTime;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'expected_work_hours': expected_work_hours,
      'description': description,
    };
  }

  factory TimeTrackingEntry.fromMap(Map<String, dynamic> map) {
    return TimeTrackingEntry(
      id: map['id'],
      start: DateTime.parse(map['start']),
      end: DateTime.parse(map['end']),
      expected_work_hours: map['expected_work_hours'],
      description: map['description'],
    );
  }

  static double calculateTotalOvertime(List<TimeTrackingEntry> entries) {
    double totalOvertime = 0.0;
    for (var entry in entries) {
      final workDuration = entry.netDuration;
      final workHours = workDuration.inHours;
      final workMinutes = workDuration.inMinutes % 60;
      final difference = workHours + workMinutes / 60 - entry.expected_work_hours;
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
      if (entry.start.isAfter(monthStart) && entry.start.isBefore(monthEnd)) {
        final workDuration = entry.netDuration;
        final workHours = workDuration.inHours;
        final workMinutes = workDuration.inMinutes % 60;
        final difference = workHours + workMinutes / 60 - entry.expected_work_hours;
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
      if (entry.start.isAfter(weekStart) && entry.start.isBefore(weekEnd)) {
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
    return months;
  }
}
