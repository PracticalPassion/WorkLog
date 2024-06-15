import 'package:flutter/cupertino.dart';
import 'package:timing/src/view/macros/ContentView.dart';
import 'package:timing/src/view/pages/home/InfoTile.dart';

class HoursThisWeekWidget extends StatelessWidget {
  final double weeklyHours;

  HoursThisWeekWidget({required this.weeklyHours});

  @override
  Widget build(BuildContext context) {
    return ContentView(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      padding: const EdgeInsets.all(10),
      child: InfoTile(
        title: 'Hours this Week',
        value: '${weeklyHours.toStringAsFixed(2)} h',
      ),
    );
  }
}
