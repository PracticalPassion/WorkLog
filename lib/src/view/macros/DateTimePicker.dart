import 'package:flutter/cupertino.dart';

class DateTimePicker5 extends StatelessWidget {
  final DateTime initialDateTime;
  final ValueChanged<DateTime> onDateTimeChanged;

  DateTimePicker5({
    super.key,
    required this.initialDateTime,
    required this.onDateTimeChanged,
  });

  static DateTime rountTime(DateTime dateTime) {
    int minute = (dateTime.minute ~/ 5) * 5;
    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoDatePicker(
      mode: CupertinoDatePickerMode.dateAndTime,
      initialDateTime: rountTime(initialDateTime),
      minuteInterval: 5,
      use24hFormat: true,
      maximumDate: DateTime.now().add(const Duration(days: 1)),
      onDateTimeChanged: (DateTime newDateTime) {
        // Anpassung der Minuten auf die nächsten 5-Minuten-Schritte
        int roundedMinute = (newDateTime.minute / 5).round() * 5;
        DateTime roundedDateTime = DateTime(
          newDateTime.year,
          newDateTime.month,
          newDateTime.day,
          newDateTime.hour,
          roundedMinute,
        );
        onDateTimeChanged(roundedDateTime);
      },
    );
  }
}
