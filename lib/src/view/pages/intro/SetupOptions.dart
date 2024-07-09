import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:work_log/src/controller/setupController.dart';
import 'package:work_log/src/view/pages/intro/SetupOption.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SetupOptions extends StatelessWidget {
  const SetupOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SetupModel>(
      builder: (context, setupModel, child) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SetupOption(
                text: AppLocalizations.of(context)!.optionTimePerDay,
                isSelected: setupModel.selectedSetup == 1,
                onTap: () => setupModel.selectSetup(1),
              ),
              SetupOption(
                text: AppLocalizations.of(context)!.optionTimePerWeek,
                isSelected: setupModel.selectedSetup == 2,
                onTap: () => setupModel.selectSetup(2),
              ),
            ],
          ),
        );
      },
    );
  }
}
