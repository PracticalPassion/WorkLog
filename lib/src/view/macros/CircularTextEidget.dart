import 'package:flutter/cupertino.dart';

class CircularTextWidget extends StatelessWidget {
  final double totalOvertimeMonth;

  CircularTextWidget({required this.totalOvertimeMonth});
  void _showExplanationDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Erklärung'),
          content: Text(
            'Dieser Wert repräsentiert die Überstunden für diesen Monat. '
            'Grün bedeutet positive Überstunden, rot bedeutet negative Überstunden.',
          ),
          actions: <Widget>[
            CupertinoButton(
              child: Text('Verstanden'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => _showExplanationDialog(context),
        child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 35,
              maxHeight: 35,
            ),
            child: Container(
              padding: EdgeInsets.all(2), // Pufferraum um den Text
              decoration: BoxDecoration(
                border: Border.all(
                  color: totalOvertimeMonth < 0 ? CupertinoColors.systemRed : CupertinoColors.systemGreen,
                  width: 2, // Randbreite
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$totalOvertimeMonth',
                  style: const TextStyle(
                    color: CupertinoColors.black, // Textfarbe
                    fontSize: 14, // Schriftgröße
                  ),
                ),
              ),
            )));
  }
}
