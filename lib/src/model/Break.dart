import 'package:sqflite_common/sqlite_api.dart';

class Break {
  int? id;
  int entryId;
  DateTime start;
  DateTime end;

  Break({
    this.id,
    required this.entryId,
    required this.start,
    required this.end,
  });

  Duration get duration => end.difference(start);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entryId': entryId,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
    };
  }

  factory Break.fromMap(Map<String, dynamic> map) {
    return Break(
      id: map['id'],
      entryId: map['entryId'],
      start: DateTime.parse(map['start']),
      end: DateTime.parse(map['end']),
    );
  }

  static getByEntryId(Database db, int i) {}
}
