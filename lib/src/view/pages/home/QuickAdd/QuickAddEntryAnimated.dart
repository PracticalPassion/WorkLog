import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:timing/src/controller/TimeEntryController.dart';
import 'package:timing/src/view/Helper/Hero/HeroRoute.dart';
import 'package:timing/src/view/pages/home/QuickAdd/QuickAddEntryForm.dart';

class QuickAddEntryWidgetAnimated extends StatefulWidget {
  @override
  _QuickAddEntryWidgetAnimatedState createState() => _QuickAddEntryWidgetAnimatedState();
}

class _QuickAddEntryWidgetAnimatedState extends State<QuickAddEntryWidgetAnimated> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeTrackingController = Provider.of<TimeTrackingController>(context, listen: false);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: timeTrackingController.lastStartTime == null ? 1.0 : _animation.value,
          child: CupertinoButton.filled(
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
          ),
        );
      },
    );
  }
}
