import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mailto/mailto.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:work_log/src/view/macros/ErrorHelper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  Future<void> _sendEmail() async {
    final mailtoLink = Mailto(
      to: ['enduranceprogr@gmail.com'],
      subject: AppLocalizations.of(context)!.mail_subject,
      body: _messageController.text,
    );

    final uri = Uri.parse('$mailtoLink');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      showDialog<String>(context: context, builder: (BuildContext context) => ErrorHandler(AppLocalizations.of(context)!.error_open_email_app, AppLocalizations.of(context)!.ok));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
        middle: Text(AppLocalizations.of(context)!.contact),
      ),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: <Widget>[
            CupertinoTextField(
              controller: _emailController,
              placeholder: AppLocalizations.of(context)!.your_email,
              keyboardType: TextInputType.emailAddress,
              clearButtonMode: OverlayVisibilityMode.editing,
            ),
            SizedBox(height: 16),
            CupertinoTextField(
              controller: _messageController,
              placeholder: AppLocalizations.of(context)!.your_message,
              maxLines: 10,
              keyboardType: TextInputType.multiline,
              clearButtonMode: OverlayVisibilityMode.editing,
            ),
            SizedBox(height: 16),
            CupertinoButton.filled(
              child: Text(AppLocalizations.of(context)!.send),
              onPressed: _sendEmail,
            ),
          ],
        ),
      ),
    );
  }
}
