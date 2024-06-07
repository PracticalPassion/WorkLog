import 'package:sqflite/sqflite.dart';

import 'package:timing/src/model/TimeEntry.dart';
import 'package:timing/src/model/Break.dart';
import 'package:timing/src/model/database/break.dart';

extension TimeTrackingEntryExtension on TimeTrackingEntry {
  static const String tableName = 'time_tracking_entries';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'description': description,
    };
  }

  static TimeTrackingEntry fromMap(Map<String, dynamic> map) {
    return TimeTrackingEntry.fromMap(map);
  }

  Future<void> save(Database db) async {
    if (id == null) {
      id = await db.insert(tableName, toMap());
    } else {
      await db.update(tableName, toMap(), where: 'id = ?', whereArgs: [id]);
    }

    // Save breaks
    for (var b in breaks) {
      b.entryId = id!;
      await b.save(db);
    }
  }

  Future<void> delete(Database db) async {
    if (id != null) {
      await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
      for (var b in breaks) {
        await b.delete(db);
      }
    }
  }

  static Future<List<TimeTrackingEntry>> getAll(Database db) async {
    List<Map<String, dynamic>> maps = await db.query(tableName);
    List<TimeTrackingEntry> entries = [];
    for (var map in maps) {
      var entry = fromMap(map);
      // List<Break?> breaks = await Break.getByEntryId(db, entry.id!);
      List<Break> breaks = [];
      if (breaks.isEmpty) {
        breaks = [
          Break(id: 0, entryId: 0, start: DateTime.now().subtract(Duration(hours: 1)), end: DateTime.now().subtract(Duration(minutes: 30))),
        ];
      }
      entry.breaks = breaks;
      entries.add(entry);
    }
    return entries;
  }
}
