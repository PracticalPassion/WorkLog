import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:timing/src/controller/TimeEntryController.dart';
import 'package:timing/src/model/TimeEntry.dart';

class EntryFormPage extends StatefulWidget {
  final TimeTrackingEntry? entry;

  EntryFormPage({this.entry});

  @override
  _EntryFormPageState createState() => _EntryFormPageState();
}

class _EntryFormPageState extends State<EntryFormPage> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _startTime;
  late DateTime _endTime;
  String _description = '';

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _startTime = widget.entry!.start;
      _endTime = widget.entry!.end;
      _description = widget.entry!.description;
    } else {
      _startTime = DateTime.now();
      _endTime = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeTrackingController = Provider.of<TimeTrackingController>(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.entry == null ? 'Add Entry' : 'Edit Entry'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text('Save'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              if (widget.entry == null) {
                timeTrackingController.saveEntry(
                  TimeTrackingEntry(
                    start: _startTime,
                    end: _endTime,
                    description: _description,
                    expected_work_hours: 8,
                  ),
                );
              } else {
                final editedEntry = widget.entry!;
                editedEntry.start = _startTime;
                editedEntry.end = _endTime;
                editedEntry.description = _description;
                timeTrackingController.saveEntry(editedEntry);
              }
              Navigator.pop(context);
            }
          },
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  initialDateTime: _startTime,
                  onDateTimeChanged: (dateTime) {
                    setState(() {
                      _startTime = dateTime;
                    });
                  },
                ),
                SizedBox(height: 16),
                CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  initialDateTime: _endTime,
                  onDateTimeChanged: (dateTime) {
                    setState(() {
                      _endTime = dateTime;
                    });
                  },
                ),
                SizedBox(height: 16),
                CupertinoTextField(
                  placeholder: 'Description',
                  onChanged: (value) {
                    setState(() {
                      _description = value;
                    });
                  },
                  controller: TextEditingController(text: _description),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
