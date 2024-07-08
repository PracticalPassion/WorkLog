import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timing/src/controller/TimeEntryController.dart';
import 'package:timing/src/controller/settingsController.dart';
import 'package:timing/src/model/WorkDay.dart';
import 'package:timing/src/view/Helper/Extentions/DurationExtention.dart';
import 'package:timing/src/view/Helper/Utils.dart';
import 'package:timing/src/view/macros/BorderWithText.dart';
import 'package:timing/src/view/macros/ContextManager.dart';
import 'package:timing/src/view/macros/DateTimePicker/DateTimePicker.dart';
import 'package:timing/src/view/macros/DateTimePicker/Helper.dart';
import 'package:timing/src/view/pages/home/Add/FormTemplate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EntryOvertimePage extends StatefulWidget {
  final WorkDay? workDay;
  final DateTime? passedDateTime;

  const EntryOvertimePage({super.key, this.workDay, this.passedDateTime});

  @override
  State<EntryOvertimePage> createState() => _EntryOvertimePageState();
}

class _EntryOvertimePageState extends State<EntryOvertimePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Duration _controllerDuraion = Duration.zero;
  late DateTime _date;
  String? _errorText;
  int groupValue = 0;

  @override
  void initState() {
    super.initState();
    _date = widget.passedDateTime ?? DateTime.now();
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
      title: "",
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
                      child: Text(AppLocalizations.of(context)!.save),
                      onPressed: () {
                        if (groupValue == 1) {
                          _controllerDuraion = settingsController.settings!.dailyWorkingHours[_date.weekday]!;
                        }

                        if (_controllerDuraion.inMinutes == 0) {
                          setState(() {
                            // _errorText = "Duration cannot be 0";
                            _errorText = AppLocalizations.of(context)!.errText5;
                          });
                          return;
                        }

                        if (timeTrackingController.hasEntryOnDate(_date, null) && groupValue == 1) {
                          setState(() {
                            // _errorText = "There is already an entry on this date";
                            _errorText = AppLocalizations.of(context)!.errText4;
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
                      child: Text(AppLocalizations.of(context)!.delete, style: TextStyle(color: CupertinoColors.destructiveRed)),
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
                    children: <int, Widget>{
                      0: Text(AppLocalizations.of(context)!.addOvertime),
                      1: Text(AppLocalizations.of(context)!.reduceOvertime),
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
              child: Text(AppLocalizations.of(context)!.date, style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(fontWeight: FontWeight.w400)),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: BorderedWithText(
                textWidget: Text(DateFormat.yMMMMd(Localizations.localeOf(context).toString()).format(_date)),
                onPressed: () {
                  if (widget.workDay != null && widget.workDay!.minutes < 0) {
                    // ContextManager.showInfoPopup(context, "Cannot change date of a negative workday");
                    ContextManager.showInfoPopup(context, AppLocalizations.of(context)!.errText3);
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
            child: Text(AppLocalizations.of(context)!.duration, style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(fontWeight: FontWeight.w400)),
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
                    // ContextManager.showInfoPopup(context, "Cannot change date of a negative workday");
                    ContextManager.showInfoPopup(context, AppLocalizations.of(context)!.errText6);
                  } else {
                    groupValue == 0
                        ? FilterHelpers.showDurationFilterWidgetPopUp(context, _controllerDuraion, (Duration newDuration) {
                            setState(() {
                              _controllerDuraion = newDuration;
                            });
                          })
                        : ContextManager.showInfoPopup(context, AppLocalizations.of(context)!.errText2);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    ]);
  }

  void showDateFilterWidgetPopUp(BuildContext context, DateTime time, Function(DateTime) onPressed) {
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
}
