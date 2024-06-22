import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timing/src/view/macros/BorderWithText.dart';

class TemplateRow extends StatelessWidget {
  final String leftName;
  final Widget rightTextWidget;
  final VoidCallback rightTextOnPressed;

  const TemplateRow({
    required this.leftName,
    required this.rightTextWidget,
    required this.rightTextOnPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(leftName, style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(fontWeight: FontWeight.w400)),
        ),
        const Spacer(),
        Align(
          alignment: Alignment.centerRight,
          child: BorderedWithText(
            onPressed: rightTextOnPressed,
            textWidget: rightTextWidget,
          ),
        ),
      ],
    );
  }
}