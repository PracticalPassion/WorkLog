import 'package:flutter/cupertino.dart';
import 'package:timing/src/view/macros/ContentView.dart';
import 'package:timing/src/view/pages/home/InfoTile.dart';

class TotalOvertimeWidget extends StatelessWidget {
  final double totalOvertime;

  TotalOvertimeWidget({required this.totalOvertime});

  @override
  Widget build(BuildContext context) {
    return ContentView(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      padding: const EdgeInsets.all(10),
      child: InfoTile(
        title: 'Total Overtime',
        value: '${totalOvertime.toStringAsFixed(2)} h',
      ),
    );
  }
}
