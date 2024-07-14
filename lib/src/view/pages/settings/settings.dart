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
  MainViewSettings({Key? key}) : super(key: key);

  @override
  State<MainViewSettings> createState() => _MainViewSettingsState();
}

class _MainViewSettingsState extends State<MainViewSettings> {
  String remainingDays = "";

  @override
  void initState() {
    super.initState();
    if (appData.plan == Plan.test) {
      PurchaseApi.getRemainingTestDays().then((value) {
        setState(() {
          remainingDays = " with remaining Days: $value";
        });
      });
    }
  }

  List<TileStrcut> listTiles_personal(BuildContext context) {
    return [
      TileStrcut(
        title: AppLocalizations.of(context)!.worktime,
        icon: CupertinoIcons.clock,
        widget: const BaseSettings(),
        onBackCallback: () {},
      )
    ];
  }

  List<TileStrcut> listTiles_about(BuildContext context) {
    return [
      TileStrcut(
        title: AppLocalizations.of(context)!.about,
        icon: CupertinoIcons.info,
        widget: AboutPage(),
      ),
      TileStrcut(title: AppLocalizations.of(context)!.contact, icon: CupertinoIcons.mail, widget: ContactPage()),
    ];
  }

  List<TileInfo> listTiles_purchases(BuildContext context) {
    return [
      TileInfo(title: "${AppLocalizations.of(context)!.currentPlan}: ${appData.plan.prettyName}$remainingDays", icon: CupertinoIcons.info, onPressed: () => PurchaseApi.perfomMagic(context)),
      TileInfo(title: AppLocalizations.of(context)!.restorePurchases, onPressed: () => PurchaseApi.restorePurchases(context), icon: CupertinoIcons.lasso),
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
              margin: EdgeInsets.all(10),
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Align(alignment: Alignment.centerLeft, child: Text(AppLocalizations.of(context)!.settings_personal_data, style: CupertinoTextThemeData().navTitleTextStyle)),
                  const SizedBox(
                    height: 10,
                  ),
                  listView(listTiles_personal(context)),
                  const SizedBox(
                    height: 60,
                  ),
                  Align(alignment: Alignment.centerLeft, child: Text(AppLocalizations.of(context)!.about, style: CupertinoTextThemeData().navTitleTextStyle)),
                  const SizedBox(
                    height: 10,
                  ),
                  listView(listTiles_about(context)),
                  const SizedBox(
                    height: 60,
                  ),
                  Align(alignment: Alignment.centerLeft, child: Text(AppLocalizations.of(context)!.purchases, style: CupertinoTextThemeData().navTitleTextStyle)),
                  const SizedBox(
                    height: 10,
                  ),
                  listView(listTiles_purchases(context), withDividers: true),
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

  TileStrcut({required title, required icon, required widget, this.onBackCallback})
      : this.title = title,
        this.icon = icon,
        this.widget = widget;

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
                  Text(title, style: CupertinoTextThemeData().navTitleTextStyle.copyWith(fontWeight: FontWeight.normal)),
                ],
              ),
            ),
            Align(
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

  TileInfo({required title, required icon, required this.onPressed})
      : this.title = title,
        this.icon = icon;

  @override
  Widget getWidget(BorderType borderType, BuildContext context) {
    return GestureDetector(
      onTap: () => onPressed(),
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: borderType.borderRadius,
        ),
        padding: const EdgeInsets.all(10),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(title,
              overflow: TextOverflow.visible,
              maxLines: 2,
              style: const CupertinoTextThemeData().navTitleTextStyle.copyWith(
                    fontWeight: FontWeight.normal,
                    color: CupertinoColors.systemBlue,
                    fontFamily: GoogleFonts.robotoMono().fontFamily,
                    fontSize: 15,
                  )),
        ),
      ),
    );
  }
}
