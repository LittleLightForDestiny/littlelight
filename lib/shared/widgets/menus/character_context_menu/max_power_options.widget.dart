import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/profile_helpers.bloc.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/shared/widgets/inventory_item/low_density_inventory_item.dart';
import 'package:little_light/shared/widgets/menus/context_menu_box.dart';
import 'package:little_light/shared/widgets/menus/context_menu_title.dart';
import 'package:provider/provider.dart';

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

class MaxPowerOptionsWidget extends StatelessWidget {
  final DestinyCharacterInfo character;

  const MaxPowerOptionsWidget({
    Key? key,
    required this.character,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final classType = character.character.classType;
    if (classType == null) return Container();
    final state = context.watch<ProfileHelpersBloc>();
    final equippableAverage = state.getEquippableAverage(classType);

    final items = state.getEquippableMaxPowerItems(classType);
    return ContextMenuBox(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ContextMenuTitle(
        "Equippable max power".translate(context),
        trailing: Text("${equippableAverage?.toStringAsFixed(2)}"),
      ),
      if (items != null)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _bucketsOrder
                .map((hash) {
                  final item = items[hash];
                  if (item == null) return null;
                  return Container(
                    height: 64,
                    width: 64,
                    margin: EdgeInsets.only(right: 2),
                    child: LowDensityInventoryItem(item),
                  );
                })
                .whereType<Widget>()
                .toList(),
          ),
        ),
    ]));
  }
}
