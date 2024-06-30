// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';

class BottomSheetWidget extends StatelessWidget {
  final Widget child;

  const BottomSheetWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(15),
            ),
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 5,
                      width: 50,
                      margin: const EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: CupertinoButton(
                      child: const Icon(CupertinoIcons.xmark_circle_fill, color: CupertinoColors.systemGrey2),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              child
            ],
          )),
    );
  }
}
