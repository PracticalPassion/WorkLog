import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timing/src/controller/TimeEntryController.dart';
import 'package:timing/src/view/Helper/Hero/HeroRoute.dart';
import 'package:timing/src/view/pages/home/QuickAdd/QuickAddEntryForm.dart';

class QuickAddEntryWidgetColored extends StatefulWidget {
  @override
  _QuickAddEntryWidgetColoredState createState() => _QuickAddEntryWidgetColoredState();
}

class _QuickAddEntryWidgetColoredState extends State<QuickAddEntryWidgetColored> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _animation;

  @override
  void initState() {
    super.initState();

    // Initialisieren Sie den AnimationController
    _controller = AnimationController(
      duration: const Duration(seconds: 2), // Dauer der Animation
      vsync: this,
    )..repeat(reverse: true);

    // Definieren Sie die Farb-Animation
    _animation = ColorTween(
      begin: Color.fromARGB(255, 61, 140, 90),
      end: Color.fromARGB(179, 35, 78, 51),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeTrackingController = Provider.of<TimeTrackingController>(context, listen: false);
    if (timeTrackingController.lastStartTime != null) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.reset(); // Optional, um zur Anfangsfarbe zurückzukehren
    }
    // AnimatedBuilder um die Animation zu verwenden
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CupertinoButton.filled(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: _animation.value,
            onPressed: () {
              Navigator.of(context).push(
                HeroDialogRoute(
                  builder: (context) => Center(
                    child: QuickAddEntryForm(),
                  ),
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeTrackingController.lastStartTime == null ? "Start" : "Stop",
                ),
                const SizedBox(width: 8),
                Icon(
                  timeTrackingController.lastStartTime == null ? CupertinoIcons.play_arrow_solid : CupertinoIcons.stop_circle_fill,
                  color: CupertinoColors.white,
                ),
              ],
            ));
      },
    );
  }
}
