import 'package:flutter/cupertino.dart';
import 'package:work_log/src/view/macros/VertivalSelection.dart';

class MonthSelectionWidget extends StatelessWidget {
  final List<String> months;
  final int selectedIndex;
  final Function(int) onSelect;

  MonthSelectionWidget({required this.months, required this.selectedIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return VerticalSelection(
      data: months,
      selectedIndex: selectedIndex,
      onSelect: onSelect,
    );
  }
}
