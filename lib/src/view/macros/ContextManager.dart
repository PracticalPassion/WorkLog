import 'package:flutter/cupertino.dart';

class ContextManager {
  static showDeletePopup(context, deleteCallback) => showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Delete Entry'),
            content: const Text('Do you really want to delete this entry?'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: const Text('Delete'),
                onPressed: () {
                  deleteCallback();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
  static showInfoPopup(context, text) => showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Info'),
            content: Text(text),
            actions: <Widget>[
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
}
