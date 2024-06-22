// overlay_component.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomOverlay extends StatelessWidget {
  final FocusNode focusNode;
  final VoidCallback onCompleted;

  const CustomOverlay({Key? key, required this.focusNode, required this.onCompleted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: CupertinoColors.activeBlue,
            child: Text('Fertig'),
            onPressed: onCompleted,
          ),
        ],
      ),
    );
  }
}
