import 'package:flutter/cupertino.dart';

class CupertinoListTile extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;

  const CupertinoListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            subtitle!,
          ],
          if (trailing != null)
            Align(
              alignment: Alignment.centerRight,
              child: trailing,
            ),
        ],
      ),
    );
  }
}
