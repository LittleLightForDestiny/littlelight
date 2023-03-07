import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/profile_helpers.bloc.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/shared/widgets/inventory_item/low_density_inventory_item.dart';
import 'package:little_light/shared/widgets/menus/context_menu_box.dart';
import 'package:little_light/shared/widgets/menus/context_menu_info_box.dart';
import 'package:little_light/shared/widgets/menus/context_menu_title.dart';
import 'package:provider/provider.dart';
import 'package:tinycolor2/tinycolor2.dart';

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
    final state = context.watch<ProfileHelpersBloc>();
    final currentAverage = state.getCurrentAverage(classType);
    final achievableAverage = state.getAchievableAverage(classType);
    final isInPinnacle = state.achievedPinnacleTier(classType);
    final goForReward = state.goForReward(classType);
    final message =
        isInPinnacle ? "Go for pinnacle reward?".translate(context) : "Go for powerful reward?".translate(context);
    final items = state.getMaxPowerItems(classType);
    return ContextMenuBox(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ContextMenuTitle(
        message,
        trailing: Text(goForReward ? "Yes".translate(context).toUpperCase() : "No".translate(context).toUpperCase()),
      ),
      IntrinsicHeight(
          child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              child: ContextMenuInfoBox(
                  child: Column(children: [
            Text("Current average".translate(context)),
            Text("${currentAverage?.toStringAsFixed(2)}"),
          ]))),
          SizedBox(width: 4),
          Expanded(
              child: ContextMenuInfoBox(
                  child: Column(children: [
            Text("Achievable average".translate(context)),
            Text("${achievableAverage?.toStringAsFixed(2)}"),
          ]))),
        ],
      )),
      if (items != null)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _bucketsOrder
                .map((hash) {
                  final item = items[hash];
                  if (item == null) return null;
                  final average = currentAverage?.floor() ?? 0;
                  final diff = item.instanceInfo?.primaryStat?.value?.compareTo(average) ?? 0;
                  String text = "Average".translate(context);
                  IconData icon = FontAwesomeIcons.equals;
                  Color bg = context.theme.onSurfaceLayers.layer3;
                  Color color = context.theme.onSurfaceLayers.layer1;
                  if (diff > 0) {
                    text = "Above".translate(context);
                    icon = FontAwesomeIcons.solidSquareCaretUp;
                    bg = context.theme.successLayers.layer0;
                    color = context.theme.successLayers.layer3;
                  }
                  if (diff < 0) {
                    text = "Below".translate(context);
                    icon = FontAwesomeIcons.solidSquareCaretDown;
                    bg = context.theme.errorLayers.layer0;
                    color = context.theme.errorLayers.layer3;
                  }
                  return Container(
                      width: 64,
                      margin: EdgeInsets.only(right: 2),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        Container(
                          height: 64,
                          margin: EdgeInsets.only(bottom: 2),
                          child: LowDensityInventoryItem(item),
                        ),
                        Container(
                          color: bg.withOpacity(.3),
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                text,
                                style: context.textTheme.caption
                                    .copyWith(color: color.mix(context.theme.onSurfaceLayers, 70)),
                              ),
                              Icon(
                                icon,
                                size: 12,
                                color: color.mix(context.theme.onSurfaceLayers, 70),
                              )
                            ],
                          ),
                        )
                      ]));
                })
                .whereType<Widget>()
                .toList(),
          ),
        ),
    ]));
  }
}
