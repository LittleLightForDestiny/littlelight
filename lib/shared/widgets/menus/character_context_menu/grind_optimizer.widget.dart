import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/shared/blocs/context_menu_options/context_menu_options.bloc.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/shared/widgets/inventory_item/low_density_inventory_item.dart';
import 'package:little_light/shared/widgets/containers/menu_box.dart';
import 'package:little_light/shared/widgets/containers/menu_info_box.dart';
import 'package:little_light/shared/widgets/containers/menu_box_title.dart';
import 'package:provider/provider.dart';
import 'package:tinycolor2/tinycolor2.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

const List<int> _bucketsOrder = [
  InventoryBucket.kineticWeapons,
  InventoryBucket.energyWeapons,
  InventoryBucket.powerWeapons,
  InventoryBucket.helmet,
  InventoryBucket.gauntlets,
  InventoryBucket.chestArmor,
  InventoryBucket.legArmor,
  InventoryBucket.classArmor,
];

class CharacterGrindOptimizerWidget extends StatelessWidget {
  final DestinyCharacterInfo character;

  const CharacterGrindOptimizerWidget({
    Key? key,
    required this.character,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final classType = character.character.classType;
    if (classType == null) return Container();
    final state = context.watch<ContextMenuOptionsBloc>();
    final currentAverage = state.getCurrentAverage(classType);
    if (currentAverage == null) return Container();
    final achievableAverage = state.getAchievableAverage(classType) ?? 0;
    final achievableDiff = achievableAverage.floor() - currentAverage.floor();
    final isInPinnacle = state.achievedPinnacleTier(classType);
    // TODO: check if it works for powerfuls
    final goForReward = state.goForReward(classType);
    final message =
        isInPinnacle ? "Go for pinnacle reward?".translate(context) : "Go for powerful reward?".translate(context);
    final items = state.getMaxPowerItems(classType);
    final itemCount = items?.length ?? 8;
    return MenuBox(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      MenuInfoBox(
        child: Column(
          children: [
            Row(children: [
              Expanded(child: Text("Current base power".translate(context) + ":")),
              Text("${currentAverage.toStringAsFixed(2)}"),
            ]),
            Container(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${currentAverage.toInt()} ", textScaleFactor: .8),
                Expanded(
                  child: StepProgressIndicator(
                      totalSteps: itemCount,
                      currentStep: ((currentAverage - currentAverage.floor()) * itemCount).round()),
                ),
                Text(" ${currentAverage.toInt() + 1}", textScaleFactor: .8),
              ],
            ),
          ],
        ),
      ),
      MenuInfoBox(
        child: Row(children: [
          Expanded(child: Text("Achievable without pinnacles".translate(context) + ":")),
          Text("+$achievableDiff  ", style: TextStyle(color: achievableDiff > 0 ? Colors.greenAccent : Colors.white)),
          Text("${achievableAverage.toStringAsFixed(2)}"),
        ]),
      ),
      MenuBoxTitle(
        message,
        trailing: Text(goForReward ? "Yes".translate(context).toUpperCase() : "No".translate(context).toUpperCase()),
      ),
      if (items != null)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _bucketsOrder
                .map((hash) {
                  final item = items[hash];
                  if (item == null) return null;
                  final average = currentAverage.toInt();
                  final diff = (item.instanceInfo?.primaryStat?.value ?? average) - average;
                  String text = "+" + diff.toString();
                  Color color = Colors.white;
                  if (diff > 0) {
                    color = Colors.greenAccent;
                  }
                  if (diff < 0) {
                    text = diff.toString();
                    color = Colors.red;
                  }
                  return Container(
                    width: 64,
                    margin: EdgeInsets.only(right: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          height: 64,
                          margin: EdgeInsets.only(bottom: 2),
                          child: LowDensityInventoryItem(item),
                        ),
                        Container(
                          color: Colors.black,
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          child: Text(text,
                              textScaleFactor: 1.1,
                              style: TextStyle(color: color, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        )
                      ],
                    ),
                  );
                })
                .whereType<Widget>()
                .toList(),
          ),
        ),
    ]));
  }
}
