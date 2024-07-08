import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timing/src/controller/TimeEntryController.dart';
import 'package:timing/src/controller/settingsController.dart';
import 'package:timing/src/model/TimeEntry.dart';
import 'package:timing/src/model/database/database.dart';
import 'package:timing/src/view/Helper/Extentions/DurationExtention.dart';
import 'package:timing/src/view/Helper/Utils.dart';
import 'package:timing/src/view/macros/BorderWithText.dart';
import 'package:timing/src/view/macros/DateTimePicker/DateTimePicker.dart';
import 'package:timing/src/view/macros/DateTimePicker/Helper.dart';
import 'package:timing/src/view/macros/Overlay.dart';
import 'package:timing/src/view/pages/home/Add/FormTemplate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EntryFormPage extends StatefulWidget {
  final TimeEntry? entry;
  final DateTime? passedStart;
  final DateTime? passedEnd;
  final String? title;

  const EntryFormPage({super.key, this.entry, this.passedStart, this.passedEnd, this.title});

  @override
  _EntryFormPageState createState() => _EntryFormPageState();
}

class _EntryFormPageState extends State<EntryFormPage> {
  late DateTime _startTime;
  late DateTime _endTime;

  final TextEditingController _controller = TextEditingController();
  TimeEntry? localEntry;
  String? _errorText;
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();

    _startTime = widget.passedStart ?? DateTimePicker5.rountTime(DateTime(now.year, now.month, now.day, now.hour, now.minute));

    _endTime = widget.passedEnd ?? DateTimePicker5.rountTime(DateTime(now.year, now.month, now.day, now.hour, now.minute));

    loadDataFrom();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    });

    if (widget.entry != null && widget.entry!.pause != null && widget.entry!.pause!.inMinutes > 0) {
      _controller.text = (widget.entry!.pause!.inMinutes).toString();
    }
  }

  Future<void> loadDataFrom() async {
    if (widget.entry != null) {
      var db = await DatabaseHelper().database;
      var entr = await TimeEntry.get(db, widget.entry!.id);
      setState(() {
        _startTime = entr.start;
        _endTime = entr.end;
        localEntry = TimeEntry(id: entr.id, start: entr.start, end: entr.end, pause: entr.pause);
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(() {});
    _controller.dispose();
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height - MediaQuery.of(context).viewInsets.bottom - 50,
        right: offset.dx,
        child: CustomOverlay(
          focusNode: _focusNode,
          onCompleted: () => _focusNode.unfocus(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeTrackingController = Provider.of<TimeTrackingController>(context);
    final settingsController = Provider.of<SettingsController>(context);

    return FormLayout(
      title: widget.title ?? (widget.entry != null ? AppLocalizations.of(context)!.changeEntry : ""),
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
                  CupertinoButton.filled(
                    child: Text(AppLocalizations.of(context)!.save),
                    onPressed: () {
                      if (_endTime.isBefore(_startTime)) {
                        setState(() {
                          // _errorText = 'End Date cannot be before Start Date';
                          _errorText = AppLocalizations.of(context)!.errText7;
                        });
                        return;
                      }

                      // check if TimeTracking entry has overtime. Add only, if  not negative

                      TimeEntryTemplate timeEntry = TimeEntryTemplate(
                        start: DateTime(_startTime.year, _startTime.month, _startTime.day, _startTime.hour, _startTime.minute),
                        end: DateTime(_endTime.year, _endTime.month, _endTime.day, _endTime.hour, _endTime.minute),
                        pause: Duration(
                          minutes: _controller.text.isEmpty
                              ? TimeEntryTemplate.calculateDesiredBreak(DateTime(_startTime.year, _startTime.month, _startTime.day, _startTime.hour, _startTime.minute),
                                  DateTime(_endTime.year, _endTime.month, _endTime.day, _endTime.hour, _endTime.minute), settingsController)
                              : (double.parse(_controller.text)).toInt(),
                        ),
                      );

                      if (!timeTrackingController.validateOvertime(timeEntry)) {
                        setState(() {
                          // _errorText = 'Day has alread a negative overtime';
                          _errorText = AppLocalizations.of(context)!.errText9;
                        });
                        return;
                      }

                      if (timeEntry.end.difference(timeEntry.start).inMinutes < 15) {
                        setState(() {
                          // _errorText = 'Minimum duration is 15 minutes';
                          _errorText = AppLocalizations.of(context)!.errText8;
                        });
                        return;
                      }

                      if (localEntry != null) {
                        if (timeTrackingController.requestEntryOverlaps(timeEntry, localEntry!)) {
                          setState(() {
                            // _errorText = 'Entry overlaps with another entry';
                            _errorText = AppLocalizations.of(context)!.errText10;
                          });
                          return;
                        }
                        localEntry!.start = timeEntry.start;
                        localEntry!.end = timeEntry.end;
                        localEntry!.pause = timeEntry.pause;
                        timeTrackingController.updateEntry(localEntry!);
                      } else {
                        if (timeTrackingController.requestEntryOverlaps(timeEntry, null)) {
                          setState(() {
                            // _errorText = 'Entry overlaps with another entry';
                            _errorText = AppLocalizations.of(context)!.errText10;
                          });
                          return;
                        }
                        timeTrackingController.saveEntryTemplate(timeEntry);
                      }
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 20),
                  if (widget.entry != null)
                    CupertinoButton(
                      child: Text(AppLocalizations.of(context)!.delete, style: const TextStyle(color: CupertinoColors.destructiveRed)),
                      onPressed: () {
                        timeTrackingController.deleteEntry(widget.entry!);
                        Navigator.pop(context);
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      children: <Widget>[
        Row(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context)!.start, style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(fontWeight: FontWeight.w400)),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: BorderedWithText(
                textWidget: Text(
                  "${DateFormat.yMMMMd(Localizations.localeOf(context).toString()).format(_startTime)}   ${DateFormat.Hm(Localizations.localeOf(context).toString()).format(_startTime)}",
                ),
                onPressed: () => showFilterWidget(context, _startTime, (newDura) {
                  setState(() {
                    _startTime = newDura;
                  });
                }),
              ),
            ),
          ],
        ),
        const Divider(color: CupertinoColors.systemGrey5),
        Row(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context)!.end, style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(fontWeight: FontWeight.w400)),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: BorderedWithText(
                textWidget: Text("${DateFormat.yMMMMd(Localizations.localeOf(context).toString()).format(_endTime)}   ${DateFormat.Hm(Localizations.localeOf(context).toString()).format(_endTime)}"),
                onPressed: () => showFilterWidget(context, _endTime, (newDura) {
                  setState(() {
                    _endTime = newDura;
                  });
                }),
              ),
            ),
          ],
        ),
        const Divider(color: CupertinoColors.systemGrey5),
        Row(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context)!.breakStr, style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(fontWeight: FontWeight.w400)),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 50,
                child: BorderedWithText(
                  textWidget: Text(_controller.text.isEmpty ? (getDuration(settingsController).formatDaration1H2M()) : Duration(minutes: int.parse(_controller.text)).formatDaration1H2M(),
                      style: TextStyle(color: _controller.text.isEmpty ? CupertinoColors.systemGrey : null)),
                  onPressed: () {
                    FilterHelpers.showDurationOnlyMinuteFilterWidgetPopUp(context, _controller.text.isEmpty ? getDuration(settingsController) : Duration(minutes: int.parse(_controller.text)),
                        (newDuration) {
                      setState(() {
                        _controller.text = newDuration.inMinutes.toString();
                      });
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Duration getDuration(settingsController) {
    return Duration(
        minutes: TimeEntryTemplate.calculateDesiredBreak(DateTime(_startTime.year, _startTime.month, _startTime.day, _startTime.hour, _startTime.minute),
            DateTime(_endTime.year, _endTime.month, _endTime.day, _endTime.hour, _endTime.minute), settingsController));
  }

  void showFilterWidget(BuildContext context, DateTime time, Function(DateTime) onPressed) {
    Utils.showSheet(
      context,
      child: SizedBox(
        height: 250,
        child: DateTimePicker5(
          initialDateTime: time,
          onDateTimeChanged: (DateTime newDateTime) {
            onPressed(newDateTime);
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
