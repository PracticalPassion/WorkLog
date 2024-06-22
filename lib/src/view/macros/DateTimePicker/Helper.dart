// filter_helpers.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timing/src/view/Helper/Utils.dart';
import 'package:timing/src/view/macros/DateTimePicker/DateTimePicker.dart';

class FilterHelpers {
  static void showDurationFilterWidgetPopUp(BuildContext context, Duration duration, Function(Duration) onPressed) {
    Utils.showSheet(
      context,
      child: SizedBox(
        height: 250,
        child: DurationPicker(
          initialDuration: duration,
          onDurationChanged: (Duration newDateTime) {
            onPressed(newDateTime);
            duration = newDateTime;
          },
        ),
      ),
      onClicked: () {
        onPressed(duration);
        Navigator.of(context).pop();
      },
    );
  }

  static void showDurationOnlyMinuteFilterWidgetPopUp(BuildContext context, Duration duration, Function(Duration) onPressed) {
    Utils.showSheet(
      context,
      child: SizedBox(
        height: 250,
        child: DurationPickerMinute(
          initialDuration: duration,
          onDurationChanged: (Duration newDateTime) {
            onPressed(newDateTime);
            duration = newDateTime;
          },
        ),
      ),
      onClicked: () {
        onPressed(duration);
        Navigator.of(context).pop();
      },
    );
  }

  static void showDateFilterWidgetPopUp(BuildContext context, DateTime time, Function(DateTime) onPressed) {
    Utils.showSheet(
      context,
      child: SizedBox(
        height: 250,
        child: DatePicker(
          initialDateTime: time,
          onDateTimeChanged: (DateTime newDateTime) {
            onPressed(newDateTime);
            time = newDateTime;
          },
        ),
      ),
      onClicked: () {
        onPressed(time);
        Navigator.of(context).pop();
      },
    );
  }

  static void showDateTimeFilterWidgetPopUp(BuildContext context, DateTime time, Function(DateTime) onPressed) {
    Utils.showSheet(
      context,
      child: SizedBox(
        height: 250,
        child: DateTimePicker5(
          initialDateTime: time,
          onDateTimeChanged: (DateTime newDateTime) {
            onPressed(newDateTime);
            time = newDateTime;
          },
        ),
      ),
      onClicked: () {
        onPressed(time);
        Navigator.of(context).pop();
      },
    );
  }
}
