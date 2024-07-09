// form_layout.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FormLayout extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final Widget? footer;
  final bool showDividers;
  final Color backgroundColor;

  const FormLayout({super.key, required this.title, required this.children, this.footer, this.showDividers = false, this.backgroundColor = CupertinoColors.systemGrey6});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        ),
      ),
      child: Column(
        children: [
          if (title != null) Text(title!, style: const CupertinoTextThemeData().navTitleTextStyle),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            child: Column(
              children: showDividers ? _buildChildrenWithDividers() : children,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          if (footer != null) footer!,
        ],
      ),
    );
  }

  List<Widget> _buildChildrenWithDividers() {
    List<Widget> childrenWithDividers = [];
    for (int i = 0; i < children.length; i++) {
      childrenWithDividers.add(children[i]);
      if (i < children.length - 1) {
        childrenWithDividers.add(
          const Divider(
            color: CupertinoColors.systemGrey5,
            height: 20,
          ),
        );
      }
    }
    return childrenWithDividers;
  }
}
