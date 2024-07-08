import 'package:flutter/cupertino.dart';
import 'package:timing/src/view/pages/home/Add/FormPage.dart';
import 'package:timing/src/view/pages/home/Add/Overtime.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FormPopUp extends StatefulWidget {
  final DateTime? passedStart;
  final DateTime? passedEnd;

  const FormPopUp({super.key, this.passedStart, this.passedEnd});

  @override
  _FormPopUpState createState() => _FormPopUpState();
}

class _FormPopUpState extends State<FormPopUp> {
  int groupValue = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      EntryFormPage(
        passedEnd: widget.passedEnd,
        passedStart: widget.passedStart,
      ),
      EntryOvertimePage(
        passedDateTime: widget.passedStart,
      ),
    ];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(children: [
            Expanded(
              child: CupertinoSlidingSegmentedControl<int>(
                  groupValue: groupValue,
                  onValueChanged: (changeFromGroupValue) {
                    setState(() {
                      groupValue = changeFromGroupValue!;
                    });
                  },
                  children: <int, Widget>{
                    0: Text(AppLocalizations.of(context)!.time),
                    1: Text(AppLocalizations.of(context)!.duration),
                  }),
            )
          ]),
        ),
        const SizedBox(
          height: 20,
        ),
        widgetOptions.elementAt(groupValue),
      ],
    );
  }
}
