import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:timing/src/controller/TimeEntryController.dart';
import 'package:timing/src/controller/settingsController.dart';
import 'package:timing/src/model/TimeEntry.dart';
import 'package:timing/src/view/Helper/Extentions/DateTimeExtention.dart';
import 'package:timing/src/view/Helper/Extentions/DurationExtention.dart';
import 'package:timing/src/view/macros/BorderWithText.dart';
import 'package:timing/src/view/macros/ContextManager.dart';
import 'package:timing/src/view/macros/DateTimePicker/DateTimePicker.dart';
import 'package:timing/src/view/macros/DateTimePicker/Helper.dart';

class QuickAddEntryForm extends StatefulWidget {
  @override
  _QuickAddEntryFormState createState() => _QuickAddEntryFormState();
}

class _QuickAddEntryFormState extends State<QuickAddEntryForm> {
  DateTime? _selectedDateTime;
  String? _errorText;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    getDateWithAdd();
  }

  getDateWithAdd() async {
    final timeTrackingController = Provider.of<TimeTrackingController>(context, listen: false);
    if (timeTrackingController.lastStartTime == null) {
      _selectedDateTime = DateTimePicker5.rountTime(DateTime.now());
    } else {
      DateTime time = timeTrackingController.lastStartTime!;
      _selectedDateTime = DateTimePicker5.rountTime(time.add(const Duration(minutes: 15)));
    }
  }

  Duration getDuration(settingsController, TimeTrackingController timeTrackingController) {
    DateTime startTime = timeTrackingController.lastStartTime!;

    if (_selectedDateTime == null) {
      return const Duration(minutes: 0);
    }

    return Duration(
        minutes: TimeEntryTemplate.calculateDesiredBreak(DateTime(startTime.year, startTime.month, startTime.day, startTime.hour, startTime.minute),
            DateTime(_selectedDateTime!.year, _selectedDateTime!.month, _selectedDateTime!.day, _selectedDateTime!.hour, _selectedDateTime!.minute), settingsController));
  }

  @override
  Widget build(BuildContext context) {
    final timeTrackingController = Provider.of<TimeTrackingController>(context);
    final settingsController = Provider.of<SettingsController>(context);

    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: IntrinsicHeight(
        child: Column(
          children: [
            timeTrackingController.lastStartTime == null
                ? const Text(
                    "Begin a new entry",
                    style: TextStyle(fontSize: 20),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Started:  ", style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.copyWith(fontSize: 15)),
                      Text(timeTrackingController.lastStartTime!.longDateWithDay(), style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Text(timeTrackingController.lastStartTime!.formatTime2H2M(), style: const TextStyle(fontSize: 20)),
                    ],
                  ),
            SizedBox(
              height: 250,
              child: DateTimePicker5(
                initialDateTime: _selectedDateTime ?? DateTime.now(),
                onDateTimeChanged: (DateTime newDateTime) {
                  setState(() {
                    _selectedDateTime = newDateTime;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            if (timeTrackingController.lastStartTime != null)
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Pause", style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(fontWeight: FontWeight.w400)),
                        ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: 50,
                            child: BorderedWithText(
                              textWidget: Text(
                                  _controller.text.isEmpty
                                      ? (getDuration(settingsController, timeTrackingController).formatDaration1H2M())
                                      : Duration(minutes: int.parse(_controller.text)).formatDaration1H2M(),
                                  style: TextStyle(color: _controller.text.isEmpty ? CupertinoColors.systemGrey : null)),
                              onPressed: () {
                                FilterHelpers.showDurationOnlyMinuteFilterWidgetPopUp(
                                    context, _controller.text.isEmpty ? getDuration(settingsController, timeTrackingController) : Duration(minutes: int.parse(_controller.text)), (newDuration) {
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
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            const SizedBox(height: 10),
            if (_errorText != null)
              Container(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  _errorText!,
                  style: const TextStyle(color: CupertinoColors.systemRed),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CupertinoButton.filled(
                  color: const Color.fromARGB(255, 203, 110, 105),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
                CupertinoButton.filled(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  onPressed: () async {
                    if (!timeTrackingController.validateOvertime(TimeEntryTemplate(start: _selectedDateTime!, end: _selectedDateTime!))) {
                      ContextManager.showInfoPopup(context,
                          "Cannot reduce to less than daily working hours. Add a Time Entry with your working time. E.g. if you work 8 hours a day, add a Time Entry with 4 hours. The remaining 4 hours will be considered as overtime.");
                      return;
                    }
                    if (timeTrackingController.lastStartTime == null) {
                      if (timeTrackingController.startTimeOverlaps(_selectedDateTime!, null)) {
                        setState(() {
                          _errorText = 'Quick add is only possible if there are no other entries after the selected time.';
                        });
                        return;
                      }

                      timeTrackingController.saveCurrentStartTime(_selectedDateTime!);
                    } else {
                      Duration breakTime = _controller.text.isEmpty ? getDuration(settingsController, timeTrackingController) : Duration(minutes: (double.parse(_controller.text)).toInt());
                      var result = timeTrackingController.stopCurrentEntry(_selectedDateTime!, settingsController, breakTime);
                      if (result != null) {
                        setState(() {
                          _errorText = result;
                        });
                        return;
                      }
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    timeTrackingController.lastStartTime == null ? "Start" : "Stop",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
