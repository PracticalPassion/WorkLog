import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomSheetWidget extends StatefulWidget {
  final Widget child;

  const BottomSheetWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _BottomSheetWidgetState createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  late DraggableScrollableController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = DraggableScrollableController();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _scrollController,
      initialChildSize: 0.9,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return NotificationListener<DraggableScrollableNotification>(
          onNotification: (notification) {
            if (notification.extent < 0.41) {
              Navigator.pop(context);
              return true;
            }
            return false;
          },
          child: Container(
            decoration: const BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onVerticalDragUpdate: (details) {
                    _scrollController.jumpTo(_scrollController.size - details.primaryDelta! / context.size!.height);
                  },
                  onVerticalDragEnd: (details) {
                    if (_scrollController.size >= 0.4 && _scrollController.size < 0.9) {
                      _scrollController.animateTo(
                        0.9,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        color: Colors.transparent,
                      ),
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
                          child: const Icon(
                            CupertinoIcons.xmark_circle_fill,
                            color: CupertinoColors.systemGrey2,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: SingleChildScrollView(
                  controller: scrollController,
                  child: widget.child,
                )),
              ],
            ),
          ),
        );
      },
    );
  }
}
