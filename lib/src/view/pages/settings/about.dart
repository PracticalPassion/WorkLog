import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
        middle: Text(AppLocalizations.of(context)!.about_app),
      ),
      child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Image.asset('assets/icon/icon.jpeg', height: 100),
                const SizedBox(height: 10),
                Text(AppLocalizations.of(context)!.appName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Divider(),
          CupertinoListTile(
            title: Text(AppLocalizations.of(context)!.version),
            subtitle: Text('${_packageInfo.version} (${_packageInfo.buildNumber})'),
          ),
          const Divider(),
          CupertinoListTile(
            title: Text(AppLocalizations.of(context)!.about_app),
            subtitle: Text(AppLocalizations.of(context)!.this_app),
          ),
          const Divider(),
          CupertinoListTile(
            title: Text(AppLocalizations.of(context)!.developed_by),
            subtitle: const Text('Kolja Bohne'),
          ),
        ],
      ),
    );
  }
}
