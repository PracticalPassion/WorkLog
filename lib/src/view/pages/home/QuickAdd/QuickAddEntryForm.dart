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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final timeTrackingController = Provider.of<TimeTrackingController>(context, listen: false);
      setState(() {
        _selectedDateTime = timeTrackingController.lastStartTime ?? DateTime.now();
      });
    });
  }

  DateTime getDateWithAdd() {
    final timeTrackingController = Provider.of<TimeTrackingController>(context, listen: false);
    if (timeTrackingController.lastStartTime == null) {
      _selectedDateTime = DateTimePicker5.rountTime(DateTime.now());
      return DateTime.now();
    }
    DateTime time = timeTrackingController.lastStartTime!;
    _selectedDateTime = DateTimePicker5.rountTime(time.add(Duration(minutes: 15)));
    return time.add(Duration(minutes: 15));
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
                initialDateTime: getDateWithAdd(),
                onDateTimeChanged: (DateTime newDateTime) {
                  setState(() {
                    _selectedDateTime = newDateTime;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
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
