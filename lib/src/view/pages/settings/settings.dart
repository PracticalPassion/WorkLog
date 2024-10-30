import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:work_log/src/controller/purchase/AppData.dart';
import 'package:work_log/src/controller/purchase/constant.dart';
import 'package:work_log/src/controller/purchase/purchase.dart';
import 'package:work_log/src/view/macros/Border.dart';
import 'package:work_log/src/view/pages/settings/BaseSettings.dart';
import 'package:work_log/src/view/pages/settings/about.dart';
import 'package:work_log/src/view/pages/settings/contact.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainViewSettings extends StatefulWidget {
  const MainViewSettings({super.key});

  @override
  State<MainViewSettings> createState() => _MainViewSettingsState();
}

class _MainViewSettingsState extends State<MainViewSettings> {
  String remainingDays = "";

  @override
  void initState() {
    super.initState();
    setPlanText();
  }

  void setPlanText() {
    if (appData.plan == Plan.test) {
      PurchaseApi.getRemainingTestDays().then((value) {
        setState(() {
          remainingDays = " ${AppLocalizations.of(context)!.remainingDays(value)}";
        });
      });
    } else {
      setState(() {
        remainingDays = "";
      });
    }
  }

  List<TileStrcut> listTilesPersonal(BuildContext context) {
    return [
      TileStrcut(
        title: AppLocalizations.of(context)!.worktime,
        icon: CupertinoIcons.clock,
        widget: const BaseSettings(),
        onBackCallback: () {},
      )
    ];
  }

  List<TileStrcut> listTilesAbout(BuildContext context) {
    return [
      TileStrcut(
        title: AppLocalizations.of(context)!.about,
        icon: CupertinoIcons.info,
        widget: AboutPage(),
      ),
      TileStrcut(title: AppLocalizations.of(context)!.contact, icon: CupertinoIcons.mail, widget: ContactPage()),
    ];
  }

  List<TileInfo> listTilesPurchases(BuildContext context) {
    return [
      TileInfo(
          title: "${AppLocalizations.of(context)!.currentPlan}: ${appData.plan.prettyName}$remainingDays",
          icon: CupertinoIcons.info,
          onPressed: () => PurchaseApi.perfomMagic(context).then((v) {
                setPlanText();
              })),
      TileInfo(
          title: AppLocalizations.of(context)!.restorePurchases,
          onPressed: () => PurchaseApi.restorePurchases(context).then((value) {
                setPlanText();
              }),
          icon: CupertinoIcons.lasso),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(AppLocalizations.of(context)!.settings_title),
          backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
        ),
        child: SafeArea(
          child: CupertinoScrollbar(
            child: Container(
              margin: const EdgeInsets.all(10),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Align(alignment: Alignment.centerLeft, child: Text(AppLocalizations.of(context)!.settings_personal_data, style: const CupertinoTextThemeData().navTitleTextStyle)),
                  const SizedBox(
                    height: 10,
                  ),
                  listView(listTilesPersonal(context)),
                  const SizedBox(
                    height: 60,
                  ),
                  Align(alignment: Alignment.centerLeft, child: Text(AppLocalizations.of(context)!.about, style: const CupertinoTextThemeData().navTitleTextStyle)),
                  const SizedBox(
                    height: 10,
                  ),
                  listView(listTilesAbout(context)),
                  const SizedBox(
                    height: 60,
                  ),
                  Align(alignment: Alignment.centerLeft, child: Text(AppLocalizations.of(context)!.purchases, style: const CupertinoTextThemeData().navTitleTextStyle)),
                  const SizedBox(
                    height: 10,
                  ),
                  listView(listTilesPurchases(context), withDividers: true),
                  const SizedBox(
                    height: 60,
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget listView(List<TileBase> tiles, {bool withDividers = false}) => ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: withDividers ? tiles.length * 2 - 1 : tiles.length, // adjust item count for dividers
        itemBuilder: (context, index) {
          if (withDividers && index.isOdd) {
            // Return a Divider for odd indices if withDividers is true
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: const Divider(height: 0, color: CupertinoColors.systemGrey4),
            );
          }
          // Return the actual widget for even indices or if withDividers is false
          final tileIndex = withDividers ? index ~/ 2 : index;
          return tiles[tileIndex].getWidget(
              tiles.length == 1
                  ? BorderType.all
                  : tileIndex == 0
                      ? BorderType.top
                      : tileIndex == tiles.length - 1
                          ? BorderType.bottom
                          : BorderType.none,
              context);
        },
      );
}

abstract class TileBase {
  Widget getWidget(BorderType borderType, BuildContext context);
}

class TileStrcut extends TileBase {
  final String title;
  final IconData icon;
  final Widget widget;
  final Function? onBackCallback;

  TileStrcut({required this.title, required this.icon, required this.widget, this.onBackCallback});
  @override
  Widget getWidget(BorderType borderType, BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        CupertinoPageRoute(builder: (context) => widget),
      ).then((value) {
        if (onBackCallback != null) {
          onBackCallback!();
        }
      }),
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: borderType.borderRadius,
        ),
        padding: const EdgeInsets.all(10),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(icon),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(title, style: const CupertinoTextThemeData().navTitleTextStyle.copyWith(fontWeight: FontWeight.normal)),
                ],
              ),
            ),
            const Align(
              alignment: Alignment.centerRight,
              child: Icon(CupertinoIcons.right_chevron, color: CupertinoColors.systemGrey),
            )
          ],
        ),
      ),
    );
  }
}

class TileInfo extends TileBase {
  final String title;
  final IconData icon;
  final Function onPressed;

  TileInfo({required this.title, required this.icon, required this.onPressed});

  @override
  Widget getWidget(BorderType borderType, BuildContext context) => CupertinoButton(
        borderRadius: BorderRadius.zero,
        minSize: 0,
        onPressed: () => onPressed(),
        padding: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: borderType.borderRadius,
          ),
          padding: const EdgeInsets.all(10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              overflow: TextOverflow.visible,
              maxLines: 2,
              style: const CupertinoTextThemeData().navTitleTextStyle.copyWith(
                    fontWeight: FontWeight.normal,
                    color: CupertinoColors.systemBlue,
                    fontFamily: GoogleFonts.robotoMono().fontFamily,
                    fontSize: 15,
                  ),
            ),
          ),
        ),
      );
}
