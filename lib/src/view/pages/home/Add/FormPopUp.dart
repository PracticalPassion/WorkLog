import 'package:flutter/cupertino.dart';
import 'package:timing/src/view/pages/home/Add/FormPage.dart';
import 'package:timing/src/view/pages/home/Add/Overtime.dart';

class FormPopUp extends StatefulWidget {
  const FormPopUp({Key? key}) : super(key: key);

  @override
  _FormPopUpState createState() => _FormPopUpState();
}

class _FormPopUpState extends State<FormPopUp> {
  int groupValue = 0;

  final List<Widget> _widgetOptions = <Widget>[
    EntryFormPage(),
    EntryOvertimePage(),
  ];

  @override
  Widget build(BuildContext context) {
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
                  children: const <int, Widget>{
                    0: Text('Form'),
                    1: Text('Overtime'),
                  }),
            )
          ]),
        ),
        const SizedBox(
          height: 20,
        ),
        _widgetOptions.elementAt(groupValue),
      ],
    );
  }
}
