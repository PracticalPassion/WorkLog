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

class DatePicker extends StatelessWidget {
  final DateTime initialDateTime;
  final ValueChanged<DateTime> onDateTimeChanged;

  DatePicker({
    super.key,
    required this.initialDateTime,
    required this.onDateTimeChanged,
  });

  static DateTime toDate(DateTime dateTime) {
    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoDatePicker(
      mode: CupertinoDatePickerMode.date,
      showDayOfWeek: true,
      initialDateTime: toDate(initialDateTime),
      maximumDate: DateTime.now().add(const Duration(days: 1)),
      onDateTimeChanged: (DateTime newDateTime) {
        DateTime roundedDateTime = DateTime(
          newDateTime.year,
          newDateTime.month,
          newDateTime.day,
        );
        onDateTimeChanged(roundedDateTime);
      },
    );
  }
}

class DurationPicker extends StatelessWidget {
  final Duration initialDuration;
  final ValueChanged<Duration> onDurationChanged;

  DurationPicker({
    super.key,
    required this.initialDuration,
    required this.onDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoTimerPicker(
      mode: CupertinoTimerPickerMode.hm,
      initialTimerDuration: initialDuration,
      minuteInterval: 5,
      onTimerDurationChanged: onDurationChanged,
    );
  }
}

class DurationPickerMinute extends StatelessWidget {
  final Duration initialDuration;
  final ValueChanged<Duration> onDurationChanged;

  DurationPickerMinute({
    super.key,
    required this.initialDuration,
    required this.onDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final initialMinutes = (initialDuration.inMinutes / 5).round(); // Initial in 5er-Schritten

    return SizedBox(
      height: 200,
      child: CupertinoPicker(
        itemExtent: 40.0, // Höhe jedes Items
        scrollController: FixedExtentScrollController(initialItem: initialMinutes),
        onSelectedItemChanged: (int index) {
          onDurationChanged(Duration(minutes: index * 5)); // Minuten in 5er-Schritten ändern
        },
        children: List<Widget>.generate(100, (int index) {
          // 12 Einträge für 0 bis 55 Minuten
          final minutes = index * 5;
          return Center(
            child: RichText(
              text: TextSpan(
                text: '$minutes',
                style: const TextStyle(
                  fontSize: 24.0, // Größere Schriftgröße für die Zahl
                  color: CupertinoColors.black,
                ),
                children: const <TextSpan>[
                  TextSpan(
                    text: ' Min.',
                    style: TextStyle(
                      fontSize: 14.0, // Kleinere Schriftgröße für "Minuten"
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
