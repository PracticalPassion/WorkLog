import 'package:flutter/cupertino.dart';

class InfoTile extends StatelessWidget {
  final String title;
  final String value;

  InfoTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: CupertinoTheme.of(context).textTheme.textStyle),
        SizedBox(height: 4),
        Text(value, style: CupertinoTheme.of(context).textTheme.navTitleTextStyle),
      ],
    );
  }
}
