import 'package:bungie_api/enums/destiny_class.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/core/blocs/loadouts/loadout_item_index.dart';
import 'package:little_light/core/blocs/loadouts/loadout_item_info.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/shared/utils/helpers/loadout_helpers.dart';
import 'package:little_light/shared/widgets/inventory_item/inventory_item_icon.dart';
import 'package:little_light/shared/widgets/ui/center_icon_workaround.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

enum LoadoutListItemAction { Equip, Edit, Delete }

typedef OnLoadoutListItemAction = void Function(LoadoutListItemAction action);

const _loadoutListItemMaxWidth = 504.0;

class LoadoutListItemWidget extends StatelessWidget {
  static const maxWidth = _loadoutListItemMaxWidth;
  final LoadoutItemIndex loadout;
  final OnLoadoutListItemAction? onAction;
  const LoadoutListItemWidget(this.loadout, {Key? key, this.onAction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(4),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: context.theme.surfaceLayers.layer1,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            height: kToolbarHeight,
            child: buildTitleBar(context),
          ),
          Expanded(child: buildLoadoutsContainer(context)),
          buildButtonBar(context)
        ]));
  }

  Widget buildLoadoutsContainer(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            buildGenericItems(context),
            buildClassSpecificItems(context, DestinyClass.Titan),
            buildClassSpecificItems(context, DestinyClass.Hunter),
            buildClassSpecificItems(context, DestinyClass.Warlock),
          ],
        ));
  }

  Widget buildTitleBar(BuildContext context) {
    final emblemHash = loadout.emblemHash;

    return Stack(
      children: [
        Positioned.fill(
            child: Container(
          color: context.theme.secondarySurfaceLayers.layer1,
        )),
        if (emblemHash != null)
          Positioned.fill(
              child: ManifestImageWidget<DestinyInventoryItemDefinition>(
            emblemHash,
            fit: BoxFit.cover,
            urlExtractor: (def) => def.secondarySpecial,
            alignment: const Alignment(-1, 0),
          )),
        buildTitle(context),
      ],
    );
  }

  Widget buildTitle(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.centerLeft,
        child: Text(
          loadout.name.toUpperCase(),
          style: TextStyle(color: Colors.grey.shade200, fontWeight: FontWeight.bold),
        ));
  }

  Widget buildButtonBar(BuildContext context) {
    final onAction = this.onAction;
    if (onAction == null) return Container();
    return Container(
      color: Theme.of(context).colorScheme.secondaryContainer,
      padding: const EdgeInsets.all(4).copyWith(top: 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: ElevatedButton(
                style: const ButtonStyle(visualDensity: VisualDensity.comfortable),
                child: Text("Equip".translate(context).toUpperCase(),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => onAction(LoadoutListItemAction.Equip),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(2),
              child: ElevatedButton(
                style: const ButtonStyle(visualDensity: VisualDensity.comfortable),
                child: Text("Edit".translate(context).toUpperCase(),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => onAction(LoadoutListItemAction.Edit),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(2),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  visualDensity: VisualDensity.comfortable,
                  backgroundColor: context.theme.errorLayers,
                ),
                child: Text("Delete".translate(context).toUpperCase(),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => onAction(LoadoutListItemAction.Delete),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGenericItems(BuildContext context) {
    final genericHashes = [
      InventoryBucket.kineticWeapons,
      InventoryBucket.energyWeapons,
      InventoryBucket.powerWeapons,
      InventoryBucket.ghost,
      InventoryBucket.vehicle,
      InventoryBucket.ships,
    ];

    final hasItem = genericHashes.any((e) => loadout.slots[e]?.genericEquipped != null);
    if (!hasItem) return Container();

    return Row(
      children: <Widget>[
        buildClassIcon(DestinyClass.Unknown),
      ]
          .followedBy(genericHashes.map((e) => buildItem(loadout.slots[e]?.genericEquipped)))
          .map((e) => Flexible(
                  child: Container(
                padding: const EdgeInsets.all(4),
                child: AspectRatio(aspectRatio: 1, child: e),
              )))
          .toList(),
    );
  }

  Widget buildClassSpecificItems(BuildContext context, DestinyClass destinyClass) {
    final genericHashes = [
      InventoryBucket.subclass,
      InventoryBucket.helmet,
      InventoryBucket.gauntlets,
      InventoryBucket.chestArmor,
      InventoryBucket.legArmor,
      InventoryBucket.classArmor,
    ];

    final hasItem = genericHashes.any((e) => loadout.slots[e]?.classSpecificEquipped[destinyClass] != null);
    if (!hasItem) return Container();

    return Row(
      children: <Widget>[
        buildClassIcon(destinyClass),
      ]
          .followedBy(genericHashes.map((e) => buildItem(loadout.slots[e]?.classSpecificEquipped[destinyClass])))
          .map((e) => Flexible(
                  child: Container(
                padding: const EdgeInsets.all(4),
                child: AspectRatio(aspectRatio: 1, child: e),
              )))
          .toList(),
    );
  }

  Widget buildClassIcon(DestinyClass destinyClass) => CenterIconWorkaround(destinyClass.icon, size: 16);

  Widget buildItem(LoadoutItemInfo? item) {
    if (item == null || item.inventoryItem == null) {
      return ManifestImageWidget<DestinyInventoryItemDefinition>(loadoutEmptySlotItemHash);
    }
    return InventoryItemIcon(item);
  }
}
