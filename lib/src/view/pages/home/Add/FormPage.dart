import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timing/src/controller/TimeEntryController.dart';
import 'package:timing/src/controller/settingsController.dart';
import 'package:timing/src/model/TimeEntry.dart';
import 'package:timing/src/model/database/database.dart';
import 'package:timing/src/view/Helper/Utils.dart';
import 'package:timing/src/view/macros/BorderWithText.dart';
import 'package:timing/src/view/macros/DateTimePicker.dart';

class EntryFormPage extends StatefulWidget {
  final TimeEntry? entry;

  EntryFormPage({this.entry});

  @override
  _EntryFormPageState createState() => _EntryFormPageState();
}

class _EntryFormPageState extends State<EntryFormPage> {
  late DateTime _startTime;
  late DateTime _endTime;
  Duration dayDuration = const Duration(minutes: 0);
  final TextEditingController _controller = TextEditingController();

  TimeEntry? localEntry;

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();
    _startTime = DateTimePicker5.rountTime(DateTime(now.year, now.month, now.day, now.hour, now.minute));
    _endTime = DateTimePicker5.rountTime(DateTime(now.year, now.month, now.day, now.hour, now.minute));

    loadDataFrom();

    // loadDataFrom();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    });
    if (widget.entry != null && widget.entry!.pause != null) {
      _controller.text = (widget.entry!.pause!.inMinutes / 60).toString();
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

  String? _errorText;

  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;

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
        child: Material(
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CupertinoButton(
                padding: EdgeInsets.symmetric(horizontal: 20),
                color: CupertinoColors.activeBlue,
                child: Text('Fertig'),
                onPressed: () {
                  _focusNode.unfocus();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeTrackingController = Provider.of<TimeTrackingController>(context);
    final settingsController = Provider.of<SettingsController>(context);

    return Container(
      decoration: const BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        ),
      ),
      child: Column(
        children: [
          Text(widget.entry != null ? "Change Entry" : "New Entry", style: const CupertinoTextThemeData().navTitleTextStyle),
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
                      child: Text("Start", style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(fontWeight: FontWeight.w400)),
                    ),
                    Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: BorderedWithText(
                          text: "${DateFormat.yMMMMd(Localizations.localeOf(context).toString()).format(_startTime)}   ${DateFormat.Hm(Localizations.localeOf(context).toString()).format(_startTime)}",
                          onPressed: () => showFilterWidget(context, _startTime, (newDura) {
                                setState(() {
                                  _startTime = newDura;
                                  dayDuration = _endTime.difference(_startTime);
                                });
                              })),
                    ),
                  ],
                ),
                const Divider(
                  color: CupertinoColors.systemGrey5,
                ),
                Row(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("End", style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(fontWeight: FontWeight.w400)),
                    ),
                    Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: BorderedWithText(
                          text: "${DateFormat.yMMMMd(Localizations.localeOf(context).toString()).format(_endTime)}   ${DateFormat.Hm(Localizations.localeOf(context).toString()).format(_endTime)}",
                          onPressed: () => showFilterWidget(context, _endTime, (newDura) {
                                setState(() {
                                  _endTime = newDura;
                                  dayDuration = _endTime.difference(_startTime);
                                });
                              })),
                    ),
                  ],
                ),
                const Divider(
                  color: CupertinoColors.systemGrey5,
                ),
                Row(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Pause", style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(fontWeight: FontWeight.w400)),
                    ),
                    Spacer(),
                    Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                            width: 50,
                            child: CupertinoTextField(
                              placeholder: dayDuration.inHours > settingsController.settings!.breakAfterHours ? (settingsController.settings!.breakDurationMinutes / 60).toString() : "0",
                              controller: _controller,
                              focusNode: _focusNode,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (value) {},
                            )))
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            _errorText ?? "",
            style: TextStyle(color: CupertinoColors.destructiveRed, fontSize: 13),
          ),
          // const Spacer(),
          Container(
            margin: const EdgeInsets.only(bottom: 90),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                // mainAxisAlignment: widget.entry != null ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.center,
                children: [
                  // maybe delete button

                  CupertinoButton.filled(
                    child: const Text("Save"),
                    onPressed: () {
                      // todo: end cannot be before start
                      if (_endTime.isBefore(_startTime)) {
                        setState(() {
                          _errorText = 'End Date cannot be before Start Date';
                        });
                        return;
                      }
                      TimeEntryTemplate timeEntry = TimeEntryTemplate(
                          // rond to minutes
                          start: DateTime(_startTime.year, _startTime.month, _startTime.day, _startTime.hour, _startTime.minute),
                          end: DateTime(_endTime.year, _endTime.month, _endTime.day, _endTime.hour, _endTime.minute),
                          pause: Duration(
                              minutes: _controller.text.isEmpty
                                  ? dayDuration.inHours > settingsController.settings!.breakAfterHours
                                      ? settingsController.settings!.breakDurationMinutes
                                      : 0
                                  : (double.parse(_controller.text) * 60).toInt()));
                      // check if overlaps

                      // minimum 15 minutes
                      if (timeEntry.end.difference(timeEntry.start).inMinutes < 15) {
                        setState(() {
                          _errorText = 'Minimum duration is 15 minutes';
                        });
                        return;
                      }

                      if (localEntry != null) {
                        if (timeTrackingController.requestEntryOverlaps(timeEntry, localEntry!)) {
                          setState(() {
                            _errorText = 'Entry overlaps with another entry';
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
                            _errorText = 'Entry overlaps with another entry';
                          });
                          return;
                        }

                        timeTrackingController.saveEntryTemplate(timeEntry);
                      }

                      Navigator.pop(context);
                    },
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  widget.entry != null
                      ? CupertinoButton(
                          child: const Text("Delete", style: TextStyle(color: CupertinoColors.destructiveRed)),
                          onPressed: () {
                            timeTrackingController.deleteEntry(widget.entry!.id);
                            Navigator.pop(context);
                          },
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showFilterWidget(BuildContext context, DateTime time, Function(DateTime) onPressed) {
    Utils.showSheet(
      context,
      child: SizedBox(
        height: 250,
        child: DateTimePicker5(
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
