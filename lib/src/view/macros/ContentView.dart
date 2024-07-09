import 'package:flutter/cupertino.dart';

class ContentView extends StatelessWidget {
  final Widget child;
  final EdgeInsets margin;
  final EdgeInsets padding;

  ContentView({required this.child, this.margin = const EdgeInsets.all(16.0), this.padding = const EdgeInsets.all(16.0)});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CupertinoColors.black.withOpacity(0.05), width: .1),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: child,
    );
  }
}
