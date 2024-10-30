import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:work_log/src/controller/TimeEntryController.dart';
import 'package:work_log/src/controller/settingsController.dart';
import 'package:work_log/src/model/TimeEntry.dart';
import 'package:work_log/src/view/Helper/Extentions/DateTimeExtention.dart';
import 'package:work_log/src/view/Helper/Extentions/DurationExtention.dart';
import 'package:work_log/src/view/macros/BorderWithText.dart';
import 'package:work_log/src/view/macros/ContextManager.dart';
import 'package:work_log/src/view/macros/DateTimePicker/DateTimePicker.dart';
import 'package:work_log/src/view/macros/DateTimePicker/Helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QuickAddEntryForm extends StatefulWidget {
  const QuickAddEntryForm({super.key});

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
      if (time.add(const Duration(minutes: 15)).isAfter(DateTime.now())) {
        _selectedDateTime = DateTimePicker5.rountTime(time.add(const Duration(minutes: 15)));
      } else {
        _selectedDateTime = DateTimePicker5.rountTime(DateTime.now());
      }
    }
  }

  Duration getBrakDurationFull(settingsController, timeTrackingController) {
    if (_controller.text.isEmpty) {
      return getBreakDuration(settingsController, timeTrackingController);
    } else {
      return Duration(minutes: int.parse(_controller.text));
    }
  }

  Duration getBreakDuration(settingsController, TimeTrackingController timeTrackingController) {
    DateTime startTime = timeTrackingController.lastStartTime!;

    if (_selectedDateTime == null) {
      return const Duration(minutes: 0);
    }

    return Duration(
        minutes: TimeEntryTemplate.calculateDesiredBreak(DateTime(startTime.year, startTime.month, startTime.day, startTime.hour, startTime.minute),
            DateTime(_selectedDateTime!.year, _selectedDateTime!.month, _selectedDateTime!.day, _selectedDateTime!.hour, _selectedDateTime!.minute), settingsController));
  }

  Duration getWorkTime(TimeTrackingController timeTrackingController, Duration breakDuration) {
    DateTime startTime = timeTrackingController.lastStartTime!;

    if (_selectedDateTime == null) {
      return const Duration(minutes: 0);
    }

    startTime = DateTime(startTime.year, startTime.month, startTime.day, startTime.hour, startTime.minute);
    DateTime endTime = DateTime(_selectedDateTime!.year, _selectedDateTime!.month, _selectedDateTime!.day, _selectedDateTime!.hour, _selectedDateTime!.minute);

    return endTime.difference(startTime) - breakDuration;
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
                ? Text(
                    AppLocalizations.of(context)!.newEntry,
                    style: const TextStyle(fontSize: 20),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("${AppLocalizations.of(context)!.started}:  ", style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.copyWith(fontSize: 15)),
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
                    // Break
                    child: Column(
                      children: [
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
                                  textWidget: Text(
                                      // _controller.text.isEmpty
                                      //     ? (getBreakDuration(settingsController, timeTrackingController).formatDaration1H2M())
                                      //     : Duration(minutes: int.parse(_controller.text)).formatDaration1H2M(),
                                      getBrakDurationFull(settingsController, timeTrackingController).formatDaration1H2M(),
                                      style: TextStyle(color: _controller.text.isEmpty ? CupertinoColors.systemGrey : null)),
                                  onPressed: () {
                                    FilterHelpers.showDurationOnlyMinuteFilterWidgetPopUp(context, getBrakDurationFull(settingsController, timeTrackingController), (newDuration) {
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
                    ),
                  ),
                  // calculated working time without break
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.workTime, style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(fontWeight: FontWeight.w400)),
                            Text(AppLocalizations.of(context)!.withoutBreak, style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle),
                          ],
                        )),
                        Align(
                            alignment: Alignment.center,
                            child: Row(children: [
                              const Icon(CupertinoIcons.timer, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                getWorkTime(timeTrackingController, getBrakDurationFull(settingsController, timeTrackingController)).formatDaration1H2M(),
                                style: const CupertinoThemeData().textTheme.textStyle.copyWith(fontSize: 20),
                              ),
                            ])),
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
                CupertinoButton(
                  color: const Color.fromARGB(255, 203, 110, 105),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                CupertinoButton.filled(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  onPressed: () async {
                    if (!timeTrackingController.validateOvertime(TimeEntryTemplate(start: _selectedDateTime!, end: _selectedDateTime!))) {
                      ContextManager.showInfoPopup(context, AppLocalizations.of(context)!.errText2);
                      return;
                    }
                    if (timeTrackingController.lastStartTime == null) {
                      if (timeTrackingController.startTimeOverlaps(_selectedDateTime!, null)) {
                        setState(() {
                          _errorText = AppLocalizations.of(context)!.errText1;
                        });
                        return;
                      }
                      timeTrackingController.saveCurrentStartTime(_selectedDateTime!);
                    } else {
                      Duration breakTime = getBrakDurationFull(settingsController, timeTrackingController);
                      var result = timeTrackingController.stopCurrentEntry(_selectedDateTime!, settingsController, breakTime, context);
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
                    timeTrackingController.lastStartTime == null ? AppLocalizations.of(context)!.start : AppLocalizations.of(context)!.stop,
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
