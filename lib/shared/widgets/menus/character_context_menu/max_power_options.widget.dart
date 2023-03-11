import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/inventory/inventory.bloc.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/shared/blocs/context_menu_options/context_menu_options.bloc.dart';
import 'package:little_light/core/blocs/selection/selection.bloc.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/shared/models/transfer_destination.dart';
import 'package:little_light/shared/widgets/inventory_item/low_density_inventory_item.dart';
import 'package:little_light/shared/widgets/containers/menu_box.dart';
import 'package:little_light/shared/widgets/containers/menu_box_title.dart';
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
  final VoidCallback onClose;

  const MaxPowerOptionsWidget({
    Key? key,
    required this.character,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final classType = character.character.classType;
    if (classType == null) return Container();
    final state = context.watch<ContextMenuOptionsBloc>();
    final equippableAverage = state.getEquippableAverage(classType);
    final items = state.getEquippableMaxPowerItems(classType);
    if (items == null) return Container();
    return MenuBox(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      MenuBoxTitle(
        "Equippable max power".translate(context),
        trailing: Text("${equippableAverage?.toStringAsFixed(2)}"),
      ),
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
      SizedBox(height: 8),
      Row(
        children: [
          Expanded(
              child: ElevatedButton(
            style: ButtonStyle(visualDensity: VisualDensity.comfortable),
            child: Text("Equip max power".translate(context).toUpperCase()),
            onPressed: () {
              context.read<InventoryBloc>().equipMultiple(
                  items.values.toList(),
                  TransferDestination(
                    TransferDestinationType.character,
                    character: character,
                  ));
              onClose();
            },
          )),
          SizedBox(width: 4),
          Expanded(
              child: ElevatedButton(
            style: ButtonStyle(visualDensity: VisualDensity.comfortable),
            child: Text("Select all".translate(context).toUpperCase()),
            onPressed: () {
              context.read<SelectionBloc>().selectItems(items.values.toList());
              onClose();
            },
          )),
        ],
      ),
    ]));
  }
}
