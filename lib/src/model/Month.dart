import 'package:intl/intl.dart';

class Month {
  final int year;
  final int month;

  Month(this.year, this.month);

  int get daysInMonth {
    if (month == 2) {
      return year % 4 == 0 ? 29 : 28;
    } else if ([4, 6, 9, 11].contains(month)) {
      return 30;
    } else {
      return 31;
    }
  }

  DateTime get start => DateTime(year, month, 1);

  DateTime get end => DateTime(year, month, daysInMonth);

  List<DateTime> get days {
    List<DateTime> days = [];
    DateTime date = start;
    while (date.isBefore(end)) {
      days.add(date);
      date = date.add(Duration(days: 1));
    }
    return days;
  }

  @override
  String toString() {
    return 'Month{year: $year, month: $month}';
  }

  isSameMonth(Month month) {
    return (month.year == year) && (month.month == this.month);
  }

  String get name => DateFormat.MMMM().format(DateTime(year, month, 1));
}
