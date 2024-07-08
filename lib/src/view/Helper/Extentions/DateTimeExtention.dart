import 'dart:ui';

import 'package:intl/intl.dart';

extension DateTimeString on DateTime {
  String formatTime2H2M() {
    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
  }

  String getWeekDayName(Locale locale) {
    // Erstellt ein Datum für den gewünschten Tag
    DateTime date = DateTime(year, month, day);
    // Nutzt DateFormat für die Kurzform des Wochentags
    DateFormat dateFormat = DateFormat.E(locale.toString());
    return dateFormat.format(date);
  }

  String shortDate() {
    return "$day.$month.";
  }

  String dayShortDate() {
    return "$day.";
  }

  String longDateWithDay() {
    return "${getWeekDayName(const Locale('de'))}, $day.$month.$year";
  }

  DateTime roundToMinute() {
    // Sekunden und Millisekunden entfernen
    DateTime truncated = DateTime(
      year,
      month,
      day,
      hour,
      minute,
    );

    // Wenn Sekunden oder Millisekunden vorhanden sind, Minute um eins erhöhen
    if (second > 0 || millisecond > 0) {
      truncated = truncated.add(Duration(minutes: 1));
    }

    return truncated;
  }

  DateTime toDay() {
    return DateTime(year, month, day);
  }
}
