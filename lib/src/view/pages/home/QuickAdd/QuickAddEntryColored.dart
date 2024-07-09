import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:work_log/src/controller/TimeEntryController.dart';
import 'package:work_log/src/view/Helper/Hero/HeroRoute.dart';
import 'package:work_log/src/view/macros/Button/ActivaStateButton.dart';
import 'package:work_log/src/view/pages/home/QuickAdd/QuickAddEntryForm.dart';

class QuickAddEntryWidgetColored extends StatefulWidget {
  @override
  _QuickAddEntryWidgetColoredState createState() => _QuickAddEntryWidgetColoredState();
}

class _QuickAddEntryWidgetColoredState extends State<QuickAddEntryWidgetColored> {
  @override
  Widget build(BuildContext context) {
    final timeTrackingController = Provider.of<TimeTrackingController>(context, listen: false);

    // AnimatedBuilder um die Animation zu verwenden
    return timeTrackingController.lastStartTime != null
        ? SeamlessGlowButton(
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Stop",
                  style: TextStyle(color: CupertinoColors.white),
                ),
                SizedBox(width: 8),
                Icon(
                  CupertinoIcons.stop_circle_fill,
                  color: CupertinoColors.white,
                ),
              ],
            ),
            onPressed: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).push(
                  HeroDialogRoute(
                    builder: (context) => Center(
                      child: QuickAddEntryForm(),
                    ),
                  ),
                );
              });
            })
        : CupertinoButton.filled(
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
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Start",
                ),
                SizedBox(width: 8),
                Icon(
                  CupertinoIcons.play_arrow_solid,
                  color: CupertinoColors.white,
                ),
              ],
            ));
  }
}
