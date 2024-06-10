import 'package:sqflite/sqflite.dart';

import 'package:timing/src/model/TimeEntry.dart';
import 'package:timing/src/model/Break.dart';
import 'package:timing/src/model/database/break.dart';

extension TimeTrackingEntryExtension on TimeTrackingEntry {
  static const String tableName = 'time_tracking_entries';
  static const String timeEntryTableName = 'time_entries';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'expected_work_hours': expectedWorkHours,
      'description': description,
    };
  }

  static TimeTrackingEntry fromMap(Map<String, dynamic> map, List<TimeEntry> timeEntries) {
    return TimeTrackingEntry(
      id: map['id'],
      expectedWorkHours: map['expected_work_hours'],
      description: map['description'],
      timeEntries: timeEntries,
    );
  }

  Future<void> save(Database db) async {
    if (id == null) {
      id = await db.insert(tableName, toMap());
    } else {
      await db.update(tableName, toMap(), where: 'id = ?', whereArgs: [id]);
      // Lösche vorhandene TimeEntries, bevor sie neu hinzugefügt werden
      await db.delete(timeEntryTableName, where: 'tracking_entry_id = ?', whereArgs: [id]);
    }

    // Save Time Entries
    for (var timeEntry in timeEntries) {
      await db.insert(
        timeEntryTableName,
        {
          'start': timeEntry.start.toIso8601String(),
          'end': timeEntry.end.toIso8601String(),
          'tracking_entry_id': id,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> delete(Database db) async {
    if (id != null) {
      await db.delete(timeEntryTableName, where: 'tracking_entry_id = ?', whereArgs: [id]);
      await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
    }
  }

  static Future<List<TimeTrackingEntry>> getAll(Database db) async {
    List<Map<String, dynamic>> maps = await db.query(tableName);
    List<TimeTrackingEntry> entries = [];

    for (var map in maps) {
      List<TimeEntry> timeEntries = await _getTimeEntriesByTrackingEntryId(db, map['id']);
      var entry = fromMap(map, timeEntries);
      // entry.timeEntries = await _getTimeEntriesByTrackingEntryId(db, entry.id!);
      entries.add(entry);
    }

    return entries;
  }

  static Future<List<TimeEntry>> _getTimeEntriesByTrackingEntryId(Database db, int trackingEntryId) async {
    List<Map<String, dynamic>> maps = await db.query(
      timeEntryTableName,
      where: 'tracking_entry_id = ?',
      whereArgs: [trackingEntryId],
    );
    return maps.map((map) => TimeEntry.fromMap(map)).toList();
  }
}
