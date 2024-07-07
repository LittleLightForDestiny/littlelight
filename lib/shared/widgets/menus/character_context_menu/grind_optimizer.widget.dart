import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/shared/modals/context_menu_overlay/character_context_menu.bloc.dart';
import 'package:little_light/shared/widgets/containers/menu_box_title.dart';
import 'package:little_light/shared/widgets/containers/menu_info_box.dart';
import 'package:little_light/shared/widgets/inventory_item/low_density_inventory_item.dart';
import 'package:provider/provider.dart';
import 'package:tinycolor2/tinycolor2.dart';
import 'package:little_light/core/blocs/selection/selection.bloc.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';

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
  final VoidCallback onClose;

  const CharacterGrindOptimizerWidget({
    Key? key,
    required this.character,
    required this.onClose,
  }) : super(key: key);

  // Build step progress bar widget to show exactly how many slot points (power levels on
  // individual items) are needed to reach the next higher power level.
  Widget _buildPartialLevelProgressBar(BuildContext context, int itemCount, double currentAverage, bool isMaxPower) {
    int currentStep = ((currentAverage - currentAverage.floor()) * itemCount).toInt();
    if (isMaxPower) {
      currentStep = itemCount;
      currentAverage--;
    }
    var bars = <Widget>[];
    Color color = context.theme.primaryLayers.layer1;
    for (int i = 0; i < itemCount; i++) {
      if (i == currentStep) color = context.theme.onSurfaceLayers.layer3;
      bars.add(
        Expanded(
          child: Container(
              height: 4,
              width: 4,
              margin: EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("${currentAverage.toInt()}", style: context.textTheme.highlight),
        Expanded(child: Container(padding: EdgeInsets.symmetric(horizontal: 4), child: Row(children: bars))),
        Text("${currentAverage.toInt() + 1}", style: context.textTheme.highlight),
      ],
    );
  }

  Widget _buildBonusPowerProgressBar(BuildContext context, int bonusPower, double bonusPowerProgress) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text("+$bonusPower", style: context.textTheme.highlight),
      Expanded(
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Stack(alignment: Alignment.center, children: [
                LinearProgressIndicator(
                    color: context.theme.primaryLayers.layer1,
                    minHeight: 4,
                    value: bonusPowerProgress,
                    backgroundColor: context.theme.onSurfaceLayers.layer3),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  Container(height: 4, width: 2, color: context.theme.surfaceLayers.layer0),
                  Container(height: 4, width: 2, color: context.theme.surfaceLayers.layer0),
                  Container(height: 4, width: 2, color: context.theme.surfaceLayers.layer0),
                ]),
              ]))),
      Text("+${bonusPower + 1}", style: context.textTheme.highlight),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final classType = character.character.classType;
    if (classType == null) return Container();
    final state = context.watch<CharacterContextMenuBloc>();
    final charCurrentAverage = state.getCurrentAverage(classType);
    if (charCurrentAverage == null) return Container();
    final acctCurrentAverage = state.getAcctCurrentAverage() ?? 0;
    final achievableAverage = state.getAcctAchievableAverage() ?? 0;
    final achievableDiff = achievableAverage.floor() - acctCurrentAverage.floor();
    final isInPinnacle = state.achievedPinnacleTier();
    final isMaxPower = state.achievedMaxPower();
    final goForReward = state.goForReward();
    final goForMessage =
        isInPinnacle ? "Go for pinnacle reward?".translate(context) : "Go for powerful reward?".translate(context);
    final achievableMessage = isInPinnacle
        ? "Achievable without pinnacles:".translate(context)
        : "Achievable without powerfuls:".translate(context);
    final bonusPower = character.artifactPower ?? 0;
    final bonusPowerProgress = state.getBonusPowerProgress();
    final items = state.getMaxPowerItems(classType);
    final acctMaxPowerItems = state.getAcctMaxPowerItems();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      MenuInfoBox(
        child: Column(
          children: [
            Row(children: [
              Expanded(child: Text("Character base power:".translate(context))),
              Text("${charCurrentAverage.toStringAsFixed(2)}",
                  style: context.textTheme.subtitle.copyWith(color: context.theme.achievementLayers)),
            ]),
            SizedBox(height: 5),
            _buildPartialLevelProgressBar(context, items?.length ?? 8, charCurrentAverage, isMaxPower)
          ],
        ),
      ),
      buildItems(context, items, charCurrentAverage),
      Container(height: 4),
      if (items != null)
        ElevatedButton(
          style: ButtonStyle(visualDensity: VisualDensity.comfortable),
          child: Text("Select all".translate(context).toUpperCase()),
          onPressed: () {
            context.read<SelectionBloc>().selectItems(items.values.toList());
            onClose();
          },
        ),
      Container(height: 8),
      MenuInfoBox(
        child: Column(
          children: [
            Row(children: [
              Expanded(child: Text("Account base power:".translate(context))),
              Text("${acctCurrentAverage.toStringAsFixed(2)}",
                  textAlign: TextAlign.right,
                  style: context.textTheme.subtitle.copyWith(color: context.theme.achievementLayers)),
            ]),
            SizedBox(height: 5),
            _buildPartialLevelProgressBar(context, items?.length ?? 8, acctCurrentAverage, isMaxPower)
          ],
        ),
      ),
      buildItems(context, acctMaxPowerItems, acctCurrentAverage),
      Container(height: 8),
      MenuInfoBox(
        child: Column(
          children: [
            Row(children: [
              Expanded(child: Text("Artifact bonus power:".translate(context))),
              Text("+${(bonusPower + bonusPowerProgress).toStringAsFixed(2)}",
                  style: context.textTheme.subtitle.copyWith(color: context.theme.upgradeLayers.layer1)),
            ]),
            SizedBox(height: 5),
            _buildBonusPowerProgressBar(context, bonusPower, bonusPowerProgress)
          ],
        ),
      ),
      MenuInfoBox(
        child: Row(children: [
          Expanded(child: Text(achievableMessage)),
          Text("+$achievableDiff  ",
              style: TextStyle(
                  color:
                      achievableDiff > 0 ? context.theme.successLayers.layer3 : context.theme.onSurfaceLayers.layer0)),
          Text("${achievableAverage.toStringAsFixed(2)}", style: TextStyle(color: context.theme.achievementLayers)),
        ]),
      ),
      MenuBoxTitle(
        goForMessage,
        trailing: Text(state.isMaxPower(charCurrentAverage)
            ? "Max".translate(context).toUpperCase()
            : goForReward
                ? "Yes".translate(context).toUpperCase()
                : "No".translate(context).toUpperCase()),
      ),
    ]);
  }

  Widget buildItems(BuildContext context, Map<int, InventoryItemInfo>? items, double currentAverage) {
    if (items == null) return Container();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _bucketsOrder
            .map((hash) {
              final item = items[hash];
              if (item == null) return null;
              final average = currentAverage.toInt();
              final diff = (item.instanceInfo?.primaryStat?.value ?? average) - average;
              String text = "+" + diff.toString();
              Color color = context.theme.surfaceLayers.layer1;
              if (diff > 0) {
                color = context.theme.successLayers.layer0;
              }
              if (diff < 0) {
                text = diff.toString();
                color = context.theme.errorLayers.layer0;
              }
              return Container(
                width: 64,
                margin: EdgeInsets.only(right: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 64,
                      margin: EdgeInsets.only(bottom: 4),
                      child: LowDensityInventoryItem(item),
                    ),
                    Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            context.theme.surfaceLayers.layer0.mix(color, 50),
                            context.theme.onSurfaceLayers.layer0.mix(color, 70),
                          ],
                        ),
                      ),
                      padding: EdgeInsets.all(2),
                      child: Text(
                        text,
                        style: context.textTheme.highlight.copyWith(
                          color: context.theme.onSurfaceLayers.mix(color, 20),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            })
            .whereType<Widget>()
            .toList(),
      ),
    );
  }
}
