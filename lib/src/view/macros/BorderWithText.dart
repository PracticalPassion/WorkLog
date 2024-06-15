import 'package:flutter/cupertino.dart';

class BorderedWithText extends StatelessWidget {
  final Function onPressed;
  final String text;

  BorderedWithText({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
          constraints: const BoxConstraints(minWidth: 50),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey5,
            // border: Border.all(color: CupertinoColors.black),
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          ),
          child: Center(child: Text(text))),
      onTap: () => onPressed(),
    );
  }
}
