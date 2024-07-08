import 'package:flutter/cupertino.dart';

class SetupOption extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const SetupOption({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey.withOpacity(0.1),
          border: Border.all(
            color: isSelected ? CupertinoTheme.of(context).primaryColor : CupertinoColors.systemGrey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                isSelected ? CupertinoIcons.check_mark : CupertinoIcons.circle,
                key: ValueKey<bool>(isSelected),
                color: isSelected ? CupertinoTheme.of(context).primaryColor : CupertinoColors.systemGrey,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: CupertinoTheme.of(context).textTheme.textStyle,
                softWrap: true,
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
