import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:work_log/src/controller/purchase/AppData.dart';
import 'package:work_log/src/controller/purchase/constant.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Paywall extends StatefulWidget {
  final Offering offering;

  const Paywall({Key? key, required this.offering}) : super(key: key);

  @override
  _PaywallState createState() => _PaywallState();
}

class _PaywallState extends State<Paywall> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Wrap(
          children: <Widget>[
            Container(
              height: 70.0,
              width: double.infinity,
              decoration: const BoxDecoration(
                  // color: kColorBar,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
              child: Center(child: Text(AppLocalizations.of(context)!.appName)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 32, bottom: 16, left: 16.0, right: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: Text(AppLocalizations.of(context)!.paywallText),
              ),
            ),
            ListView.builder(
              itemCount: widget.offering.availablePackages.length,
              itemBuilder: (BuildContext context, int index) {
                var myProductList = widget.offering.availablePackages;
                return Card(
                  color: Colors.black,
                  child: ListTile(
                      onTap: () async {
                        try {
                          CustomerInfo customerInfo = await Purchases.purchasePackage(myProductList[index]);
                          EntitlementInfo? entitlement = customerInfo.entitlements.all[entitlementID];
                          appData.entitlementIsActive = entitlement?.isActive ?? false;
                          // ignore: empty_catches
                        } catch (e) {}

                        setState(() {});
                        Navigator.pop(context);
                      },
                      title: Text(
                        myProductList[index].storeProduct.title,
                        style: const CupertinoTextThemeData().textStyle.copyWith(color: CupertinoColors.white, fontSize: 14.0),
                      ),
                      subtitle: Text(
                        myProductList[index].storeProduct.description,
                        style: const CupertinoTextThemeData().textStyle.copyWith(color: CupertinoColors.white, fontSize: 14.0),
                      ),
                      trailing: Text(
                        myProductList[index].storeProduct.priceString,
                        style: const CupertinoTextThemeData().textStyle.copyWith(color: CupertinoColors.white, fontSize: 14.0),
                      )),
                );
              },
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 32, bottom: 16, left: 16.0, right: 16.0),
              child: Column(
                children: [
                  SizedBox(
                    // width: double.infinity,
                    child: Text.rich(
                      TextSpan(
                        text: footerText,
                        style: const CupertinoTextThemeData().textStyle.copyWith(fontSize: 11.0),
                        children: [
                          TextSpan(
                            text: AppLocalizations.of(context)!.termsOfUse,
                            style: const TextStyle(
                              color: CupertinoColors.activeBlue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launchUrl(Uri.parse('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'));
                              },
                          ),
                          const TextSpan(text: ' '),
                          TextSpan(text: AppLocalizations.of(context)!.and),
                          const TextSpan(text: ' '),
                          TextSpan(
                            text: AppLocalizations.of(context)!.privacyPolicy,
                            style: const TextStyle(
                              color: CupertinoColors.activeBlue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launchUrl(Uri.parse('https://koljabohne.github.io/endurancepro.github.io/'));
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
