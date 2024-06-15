import 'package:flutter/cupertino.dart';
import 'package:timing/src/model/Month.dart';

class MonthDisplay extends StatelessWidget {
  final Month month;

  MonthDisplay({required this.month});

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding only below
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(month.getName(Localizations.localeOf(context)),
          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              )),
    );
  }
}
