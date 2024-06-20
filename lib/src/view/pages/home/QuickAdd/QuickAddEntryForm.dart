import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:timing/src/controller/TimeEntryController.dart';
import 'package:timing/src/view/macros/DateTimePicker.dart';

class QuickAddEntryForm extends StatefulWidget {
  @override
  _QuickAddEntryFormState createState() => _QuickAddEntryFormState();
}

class _QuickAddEntryFormState extends State<QuickAddEntryForm> {
  DateTime? _selectedDateTime;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    getDateWithAdd();
  }

  getDateWithAdd() {
    final timeTrackingController = Provider.of<TimeTrackingController>(context, listen: false);
    if (timeTrackingController.lastStartTime == null) {
      _selectedDateTime = DateTimePicker5.rountTime(DateTime.now());
    } else {
      DateTime time = timeTrackingController.lastStartTime!;
      _selectedDateTime = DateTimePicker5.rountTime(time.add(const Duration(minutes: 15)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeTrackingController = Provider.of<TimeTrackingController>(context);

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
                : Text(timeTrackingController.lastStartTime.toString()),
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
                  onPressed: () {
                    if (timeTrackingController.lastStartTime == null) {
                      if (timeTrackingController.startTimeOverlaps(_selectedDateTime!, null)) {
                        setState(() {
                          _errorText = 'Entry overlaps with another entry';
                        });
                        return;
                      }

                      timeTrackingController.saveCurrentStartTime(_selectedDateTime!);
                    } else {
                      timeTrackingController.stopCurrentEntry(_selectedDateTime!);
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
