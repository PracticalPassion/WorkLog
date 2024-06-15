import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:timing/src/controller/TimeEntryController.dart';
import 'package:timing/src/view/Helper/Hero/HeroRoute.dart';
import 'package:timing/src/view/pages/home/QuickAdd/QuickAddEntryForm.dart';

class QuickAddEntryWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final timeTrackingController = Provider.of<TimeTrackingController>(context, listen: false);

    return CupertinoButton.filled(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      onPressed: () {
        Navigator.of(context).push(
          HeroDialogRoute(
            builder: (context) => Center(
              child: QuickAddEntryForm(),
            ),
          ),
        );
      },
      child: Text(
        timeTrackingController.lastStartTime == null ? "Start" : "Stop",
      ),
    );
  }
}
