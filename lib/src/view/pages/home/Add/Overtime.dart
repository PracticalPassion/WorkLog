import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timing/src/controller/TimeEntryController.dart';
import 'package:timing/src/controller/settingsController.dart';
import 'package:timing/src/model/WorkDay.dart';
import 'package:timing/src/view/Helper/Extentions/DurationExtention.dart';
import 'package:timing/src/view/macros/BorderWithText.dart';
import 'package:timing/src/view/macros/ContextManager.dart';
import 'package:timing/src/view/macros/DateTimePicker/Helper.dart';
import 'package:timing/src/view/pages/home/Add/FormTemplate.dart';

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
  int groupValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    if (widget.workDay != null) {
      _date = widget.workDay?.date as DateTime;
      _controllerDuraion = widget.workDay!.getDuration();
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
    final settingsController = Provider.of<SettingsController>(context, listen: false);

    return FormLayout(
      title: "Offset Overtime",
      footer: Column(
        children: [
          Text(
            _errorText ?? "",
            style: const TextStyle(color: CupertinoColors.destructiveRed, fontSize: 13),
          ),
          const SizedBox(height: 5),
          Container(
            margin: const EdgeInsets.only(bottom: 90),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                children: [
                  if (!(widget.workDay != null && widget.workDay!.minutes < 0))
                    CupertinoButton.filled(
                      child: const Text("Save"),
                      onPressed: () {
                        if (groupValue == 1) {
                          _controllerDuraion = settingsController.settings!.dailyWorkingHours[_date.weekday]!;
                        }

                        if (_controllerDuraion.inMinutes == 0) {
                          setState(() {
                            _errorText = "Duration cannot be 0";
                          });
                          return;
                        }

                        if (timeTrackingController.hasEntryOnDate(_date, null) && groupValue == 1) {
                          setState(() {
                            _errorText = "There is already an entry on this date";
                          });
                          return;
                        }

                        if (widget.workDay != null) {
                          widget.workDay!.date = _date;
                          widget.workDay!.minutes = groupValue == 0 ? _controllerDuraion.inMinutes : -_controllerDuraion.inMinutes;
                          timeTrackingController.updateWorkDay(widget.workDay!);
                          Navigator.pop(context);
                        } else {
                          WorkDay workDay = WorkDay(date: _date, minutes: groupValue == 0 ? _controllerDuraion.inMinutes : -_controllerDuraion.inMinutes, type: WorkDayType.overtime);
                          timeTrackingController.saveWorkDay(workDay);
                          Navigator.pop(context);
                        }
                      },
                    ),
                  const SizedBox(height: 20),
                  if (widget.workDay != null)
                    CupertinoButton(
                      child: const Text("Delete", style: TextStyle(color: CupertinoColors.destructiveRed)),
                      onPressed: () {
                        timeTrackingController.deleteWorkDay(widget.workDay!);
                        Navigator.pop(context);
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(children: [
            if (!(widget.workDay != null && widget.workDay!.minutes < 0))
              Expanded(
                child: CupertinoSlidingSegmentedControl<int>(
                    groupValue: groupValue,
                    onValueChanged: (changeFromGroupValue) {
                      setState(() {
                        groupValue = changeFromGroupValue!;
                      });
                    },
                    children: const <int, Widget>{
                      0: Text('Add'),
                      1: Text('Rduce'),
                    }),
              )
          ]),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Date", style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(fontWeight: FontWeight.w400)),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: BorderedWithText(
                textWidget: Text(DateFormat.yMMMMd(Localizations.localeOf(context).toString()).format(_date)),
                onPressed: () {
                  if (widget.workDay != null && widget.workDay!.minutes < 0) {
                    ContextManager.showInfoPopup(context, "Cannot change date of a negative workday");
                  } else {
                    FilterHelpers.showDateFilterWidgetPopUp(context, _date, (newDura) {
                      setState(() {
                        _date = newDura;
                      });
                    });
                  }
                },
              ),
            ),
          ],
        ),
        const Divider(color: CupertinoColors.systemGrey5),
        buildOvertime(settingsController),
      ],
    );
  }

  Widget buildOvertime(SettingsController settingsController) {
    return Column(children: [
      Row(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Duration", style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(fontWeight: FontWeight.w400)),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: groupValue == 0 ? CupertinoColors.systemGrey5 : CupertinoColors.systemRed),
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: BorderedWithText(
                textWidget: Text(groupValue == 0 ? (_controllerDuraion.inMinutes / 60).toStringAsFixed(2) : settingsController.settings!.dailyWorkingHours[_date.weekday]!.formatDarationH2M()),
                onPressed: () {
                  if (widget.workDay != null && widget.workDay!.minutes < 0) {
                    ContextManager.showInfoPopup(context, "Cannot change date of a negative workday");
                  } else {
                    groupValue == 0
                        ? FilterHelpers.showDurationFilterWidgetPopUp(context, _controllerDuraion, (Duration newDuration) {
                            setState(() {
                              _controllerDuraion = newDuration;
                            });
                          })
                        : ContextManager.showInfoPopup(context,
                            "Cannot reduce to less than daily working hours. Add a Time Entry with your working time. E.g. if you work 8 hours a day, add a Time Entry with 4 hours. The remaining 4 hours will be considered as overtime.");
                  }
                },
              ),
            ),
          ),
        ],
      ),
    ]);
  }
}
