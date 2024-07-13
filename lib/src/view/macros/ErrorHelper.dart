import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ErrorHandler extends StatefulWidget {
  final String _message;
  final String _klick;
  ErrorHandler(this._message, this._klick);
  @override
  _ErrorHandler createState() => _ErrorHandler(_message, _klick);
}

class _ErrorHandler extends State<ErrorHandler> {
  String _message;
  String _klick;

  _ErrorHandler(this._message, this._klick);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(AppLocalizations.of(context)!.error),
      content: Text(_message),
      actions: <Widget>[
        CupertinoDialogAction(
            child: Text(_klick, style: TextStyle(color: CupertinoColors.activeBlue)),
            onPressed: () {
              Navigator.pop(context);
            }),
      ],
    );
  }
}

class InfoHandler extends StatefulWidget {
  final String _message;
  final String title;
  InfoHandler(this._message, this.title);
  @override
  _InfoHandlerState createState() => _InfoHandlerState();
}

class _InfoHandlerState extends State<InfoHandler> {
  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(widget.title),
      content: Text(widget._message),
      actions: <Widget>[],
    );
  }
}
