import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:work_log/src/controller/settingsController.dart';
import 'package:work_log/src/model/UserSettings.dart';
import 'package:work_log/src/view/Helper/Extentions/DurationExtention.dart';
import 'package:work_log/src/view/Helper/Utils.dart';
import 'package:work_log/src/view/macros/DateTimePicker/DateTimePicker.dart';
import 'package:work_log/src/view/macros/Overlay.dart';
import 'package:work_log/src/view/macros/TemplateRow.dart';
import 'package:work_log/src/view/pages/home/Add/FormTemplate.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:work_log/src/view/pages/settings/ButtonOverlay.dart';

class TimeSheetSettingsWidget extends StatefulWidget {
  final List<int> sortedWeekDays;
  final Map<int, Duration> dailyWorkingHours;
  final int breakDurationMinutes;
  final Duration breakAfterHours;
  final Function afterSuccess;
  final Function(dynamic, int, Duration) onSettingsChanged;
  final bool detailWidget;
  final bool showTitle;

  final Duration weekDuration = const Duration(hours: 40);

  const TimeSheetSettingsWidget({
    super.key,
    required this.sortedWeekDays,
    required this.dailyWorkingHours,
    required this.breakDurationMinutes,
    required this.breakAfterHours,
    required this.onSettingsChanged,
    required this.afterSuccess,
    this.detailWidget = true,
    this.showTitle = true,
  });

  @override
  _TimeSheetSettingsWidgetState createState() => _TimeSheetSettingsWidgetState();
}

class _TimeSheetSettingsWidgetState extends State<TimeSheetSettingsWidget> {
  String getDayName(BuildContext context, int weekday) {
    DateTime referenceDate = DateTime(2022, 1, 3 + (weekday - DateTime.monday));
    return DateFormat.EEEE(Localizations.localeOf(context).toString()).format(referenceDate);
  }

  final TextEditingController _controller = TextEditingController();

  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _controller.text = (widget.weekDuration.inHours).toString();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    });
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
    return Container(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          // const SizedBox(height: 90),
          widget.detailWidget ? detailDayWidget(context) : weekWidget(context),
          FormLayout(
              // backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
              backgroundColor: CupertinoColors.systemGrey6,
              showDividers: true,
              title: null,
              children: [
                TemplateRow(
                  leftName: (AppLocalizations.of(context)!.settingsBreakDuration),
                  rightTextWidget: Text(widget.breakDurationMinutes.toString()),
                  rightTextOnPressed: () {
                    showFilterMinuteWidget(context, Duration(minutes: widget.breakDurationMinutes), (time) {
                      widget.onSettingsChanged(widget.dailyWorkingHours, time.inMinutes, widget.breakAfterHours);
                    });
                  },
                ),
                TemplateRow(
                  leftName: (AppLocalizations.of(context)!.settingsBreakAfter),
                  rightTextWidget: Text(widget.breakAfterHours.formatDarationH2M()),
                  rightTextOnPressed: () {
                    showFilterWidget(context, widget.breakAfterHours, (time) {
                      widget.onSettingsChanged(widget.dailyWorkingHours, widget.breakDurationMinutes, time);
                    });
                  },
                ),
              ]),
          IntrinsicWidth(
            child: CupertinoButton.filled(
              child: Text(AppLocalizations.of(context)!.save),
              onPressed: () async {
                final settings = UserSettings(
                  dailyWorkingHours: widget.dailyWorkingHours,
                  breakDurationMinutes: widget.breakDurationMinutes,
                  breakAfterHours: widget.breakAfterHours,
                );
                final settingsController = Provider.of<SettingsController>(context, listen: false);
                await settingsController.saveUserSettings(settings);

                widget.afterSuccess();
              },
            ),
          ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }

  void showFilterWidget(BuildContext context, Duration time, Function(Duration) onPressed) {
    Utils.showSheet(
      context,
      child: SizedBox(
        height: 250,
        child: DurationPicker(
          initialDuration: time,
          onDurationChanged: (Duration newDateTime) {
            time = newDateTime;

            onPressed(newDateTime);
          },
        ),
      ),
      onClicked: () {
        onPressed(time);
        Navigator.of(context).pop();
      },
    );
  }

  void showFilterMinuteWidget(BuildContext context, Duration time, Function(Duration) onPressed) {
    Utils.showSheet(
      context,
      child: SizedBox(
        height: 250,
        child: DurationPickerMinute(
          initialDuration: time,
          onDurationChanged: (Duration newDateTime) {
            time = newDateTime;
            onPressed(newDateTime);
          },
        ),
      ),
      onClicked: () {
        onPressed(time);
        Navigator.of(context).pop();
      },
    );
  }

  Widget detailDayWidget(context) {
    return FormLayout(
      backgroundColor: CupertinoColors.systemGrey6,
      showDividers: true,
      title: widget.showTitle ? AppLocalizations.of(context)!.settings : null,
      children: [
        ...widget.sortedWeekDays.map((day) {
          return TemplateRow(
            leftName: getDayName(context, day),
            rightTextWidget: Text(widget.dailyWorkingHours[day]!.formatDarationH2M()),
            rightTextOnPressed: () {
              showFilterWidget(context, widget.dailyWorkingHours[day]!, (time) {
                widget.onSettingsChanged({day: time}, widget.breakDurationMinutes, widget.breakAfterHours);
              });
            },
          );
        })
      ],
    );
  }

  Widget weekWidget(context) {
    return FormLayout(backgroundColor: CupertinoColors.systemGrey6, showDividers: true, title: AppLocalizations.of(context)!.settings, children: [
      TemplateRow(
          leftName: AppLocalizations.of(context)!.workWeekRange,
          replaceRightWidget: true,
          rightTextWidget: SizedBox(
            width: 60,
            child: NumberInputWithDoneButton(
              controller: _controller,
              placeholder: '',
              onCompleted: (str) {
                widget.onSettingsChanged(
                  str,
                  widget.breakDurationMinutes,
                  widget.breakAfterHours,
                );
              },
            ),
          ),
          rightTextOnPressed: () {}),
    ]);
  }
}
