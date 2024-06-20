import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timing/src/controller/TimeEntryController.dart';
import 'package:timing/src/model/WorkDay.dart';
import 'package:timing/src/view/Helper/Utils.dart';
import 'package:timing/src/view/macros/BorderWithText.dart';
import 'package:timing/src/view/macros/DateTimePicker.dart';

class EntryOvertimePage extends StatefulWidget {
  final WorkDay? workDay;

  const EntryOvertimePage({super.key, this.workDay});

  @override
  State<EntryOvertimePage> createState() => _EntryOvertimePageState();
}

class _EntryOvertimePageState extends State<EntryOvertimePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  Duration _controllerDuraion = Duration.zero;
  DateTime _date = DateTime.now();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    if (widget.workDay != null) {
      _date = widget.workDay?.date as DateTime;
      _controllerDuraion = Duration(minutes: (widget.workDay!.getMinutes()));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeTrackingController = Provider.of<TimeTrackingController>(context, listen: false);

    return Column(
      children: [
        const Divider(
          height: 20,
          thickness: 1,
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Date", style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(fontWeight: FontWeight.w400)),
                  ),
                  Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: BorderedWithText(
                        text: DateFormat.yMMMMd(Localizations.localeOf(context).toString()).format(_date),
                        onPressed: () => showDateFilterWidget(context, _date, (newDura) {
                              setState(() {
                                _date = newDura;
                              });
                            })),
                  )
                ],
              ),
              const Divider(
                color: CupertinoColors.systemGrey5,
              ),
              Row(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Duration", style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(fontWeight: FontWeight.w400)),
                  ),
                  Spacer(),
                  Align(
                      alignment: Alignment.centerRight,
                      child: BorderedWithText(
                        text: "${(_controllerDuraion.inMinutes / 60).toStringAsFixed(2)}",
                        onPressed: () {
                          showFilterWidget(context, _controllerDuraion, (Duration newDuration) {
                            setState(() {
                              _controllerDuraion = newDuration;
                            });
                          });
                        },
                      ))
                ],
              ),
            ],
          ),
        ),
        Text(
          _errorText ?? "",
          style: TextStyle(color: CupertinoColors.destructiveRed, fontSize: 13),
        ),
        const SizedBox(
          height: 20,
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 90),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: CupertinoButton.filled(
              child: const Text("Save"),
              onPressed: () {
                if (_controllerDuraion.inMinutes == 0) {
                  setState(() {
                    _errorText = "Duration cannot be 0";
                  });
                  return;
                }

                if (widget.workDay != null) {
                  widget.workDay!.date = _date;
                  widget.workDay!.minutes = _controllerDuraion.inMinutes;
                  timeTrackingController.updateWorkDay(widget.workDay!);
                  Navigator.pop(context);
                } else {
                  WorkDay workDay = WorkDay(date: _date, minutes: _controllerDuraion.inMinutes, type: WorkDayType.overtime);
                  timeTrackingController.saveWorkDay(workDay);
                  Navigator.pop(context);
                }
              },
            ),
          ),
        )
      ],
    );
  }

  void showFilterWidget(BuildContext context, Duration duration, Function(Duration) onPressed) {
    Utils.showSheet(
      context,
      child: SizedBox(
        height: 250,
        child: DurationPicker(
          initialDuration: duration,
          onDurationChanged: (Duration newDateTime) {
            setState(() {
              duration = newDateTime;
            });
          },
        ),
      ),
      onClicked: () {
        onPressed(duration);
        Navigator.of(context).pop();
      },
    );
  }

  void showDateFilterWidget(BuildContext context, DateTime time, Function(DateTime) onPressed) {
    Utils.showSheet(
      context,
      child: SizedBox(
        height: 250,
        child: DatePicker(
          initialDateTime: time,
          onDateTimeChanged: (DateTime newDateTime) {
            setState(() {
              time = newDateTime;
            });
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
