import 'package:timing/src/model/Break.dart';
import 'package:sqflite/sqflite.dart';

extension BreakExtension on Break {
  static const String tableName = 'breaks';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entryId': entryId,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
    };
  }

  static Break fromMap(Map<String, dynamic> map) {
    return Break(
      id: map['id'],
      entryId: map['entryId'],
      start: DateTime.parse(map['start']),
      end: DateTime.parse(map['end']),
    );
  }

  Future<void> save(Database db) async {
    if (id == null) {
      id = await db.insert(tableName, toMap());
    } else {
      await db.update(tableName, toMap(), where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<void> delete(Database db) async {
    if (id != null) {
      await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
    }
  }

  static Future<List<Break>> getByEntryId(Database db, int entryId) async {
    List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'entryId = ?',
      whereArgs: [entryId],
    );
    return maps.map((map) => fromMap(map)).toList();
  }
}
