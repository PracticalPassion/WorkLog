import 'package:flutter/cupertino.dart';
import 'package:timing/src/view/pages/intro/SetupOptions.dart';
import 'package:timing/src/view/pages/intro/Intoduction.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      // backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    Text(
                      AppLocalizations.of(context)!.introFirstPageTitle,
                      style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
                    ),
                    const SizedBox(height: 40),
                    Text(
                      AppLocalizations.of(context)!.introFirstPageText,
                      style: CupertinoTheme.of(context).textTheme.textStyle,
                    ),
                  ],
                ),
              ),
              const SetupOptions(),
              CupertinoButton.filled(
                child: Text(AppLocalizations.of(context)!.next),
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => IntroductionPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}
