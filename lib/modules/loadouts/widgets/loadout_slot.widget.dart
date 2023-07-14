import 'package:bungie_api/enums/destiny_class.dart';
import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/core/blocs/loadouts/loadout_item_index.dart';
import 'package:little_light/core/blocs/loadouts/loadout_item_info.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/helpers/loadout_helpers.dart';
import 'package:little_light/shared/widgets/headers/header.wiget.dart';
import 'package:little_light/shared/widgets/inventory_item/inventory_item_icon.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

class LoadoutItemAction {
  final bool equipped;
  final LoadoutItemInfo? item;
  final DestinyClass? classType;

  const LoadoutItemAction(this.equipped, {this.item, this.classType});
}

typedef OnLoadoutItemAction = void Function(LoadoutItemAction action);

class LoadoutSlotWidget extends StatelessWidget with ProfileConsumer, ManifestConsumer {
  final int bucketHash;
  final OnLoadoutItemAction? onItemTap;
  final LoadoutIndexSlot? slot;
  final Set<DestinyClass>? availableClasses;
  LoadoutSlotWidget(this.bucketHash, {Key? key, required this.slot, this.onItemTap, this.availableClasses})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bucketDef = context.definition<DestinyInventoryBucketDefinition>(this.bucketHash);
    final hasTransferDestination = bucketDef?.hasTransferDestination ?? false;
    return Column(children: [
      HeaderWidget(child: Text(bucketDef?.displayProperties?.name?.toUpperCase() ?? "")),
      buildSlotBlock(
        context,
        headerText: "Equip".translate(context),
      ),
      if (hasTransferDestination)
        buildSlotBlock(
          context,
          headerText: "Transfer".translate(context),
          isEquipment: false,
        ),
      Container(height: 8)
    ]);
  }

  Widget buildSlotBlock(BuildContext context, {required String headerText, bool isEquipment = true}) {
    return Container(
        margin: EdgeInsets.only(top: 4),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: context.theme.surfaceLayers.layer1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            buildBlockTitle(context, headerText),
            Container(
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.all(4),
                reverse: true,
                child: buildItemIcons(context, isEquipment: isEquipment),
              ),
            ),
          ],
        ));
  }

  Widget buildBlockTitle(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: context.theme.surfaceLayers.layer0,
      ),
      child: Text(text.toUpperCase(), style: context.textTheme.highlight),
    );
  }

  Widget buildItemIcons(BuildContext context, {bool isEquipment = true}) {
    if (isEquipment) return buildEquipmentItems(context);
    return buildTransferItems(context);
  }

  Widget buildEquipmentItems(BuildContext context) {
    final isClassSpecific = loadoutClassSpecificBucketHashes.contains(bucketHash);
    final classSlots = isClassSpecific
        ? this.availableClasses
        : this.availableClasses?.where((e) => slot?.classSpecificEquipped[e]?.inventoryItem != null);
    final showGenericSlot = (classSlots?.length ?? 0) < (this.availableClasses?.length ?? 0);
    return Row(
      children: [
        if (classSlots != null)
          ...classSlots
              .map((e) => buildItemIcon(
                    context,
                    classType: e,
                    loadoutIndexItem: slot?.classSpecificEquipped[e],
                    equipped: true,
                  ))
              .toList(),
        if (showGenericSlot)
          buildItemIcon(
            context,
            loadoutIndexItem: slot?.genericEquipped,
            equipped: true,
          ),
      ],
    );
  }

  Widget buildTransferItems(BuildContext context) {
    final items = slot?.unequipped.where((i) => i.inventoryItem != null).toList() ?? [];
    final showEmptySlot = items.length < 9;
    return Row(
      children: [
        ...items
            .map((e) => buildItemIcon(
                  context,
                  loadoutIndexItem: e,
                ))
            .toList(),
        if (showEmptySlot) buildItemIcon(context),
      ],
    );
  }

  Widget buildItemIcon(BuildContext context,
      {LoadoutItemInfo? loadoutIndexItem, DestinyClass? classType, bool equipped = false}) {
    final hasItem = loadoutIndexItem?.inventoryItem != null;
    final hasPlugs = loadoutIndexItem?.itemPlugs.isNotEmpty ?? false;
    return Container(
        width: 64,
        height: 64,
        margin: EdgeInsets.all(2),
        child: Stack(
            children: [
          hasItem ? buildItemSlotIcon(context, loadoutIndexItem) : buildEmptySlotIcon(context, classType),
          hasPlugs ? Positioned(child: buildPlugsIcon(context), bottom: 0, right: 0) : null,
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onItemTap?.call(LoadoutItemAction(
                equipped,
                item: loadoutIndexItem,
                classType: classType,
              )),
            ),
          ),
        ].whereType<Widget>().toList()));
  }

  Widget buildItemSlotIcon(BuildContext context, LoadoutItemInfo? loadoutItem, {DestinyClass? classType}) {
    final item = loadoutItem?.inventoryItem;
    if (item == null) return buildEmptySlotIcon(context, classType);
    return Stack(children: [
      InventoryItemIcon(item),
    ]);
  }

  Widget buildEmptySlotIcon(BuildContext context, DestinyClass? classType) {
    return Stack(children: [
      ManifestImageWidget<DestinyInventoryItemDefinition>(loadoutEmptySlotItemHash),
      Positioned.fill(
        child: Icon(
          classType?.icon ?? Icons.add_circle_outline,
          color: context.theme.onSurfaceLayers.layer2,
          size: 24,
        ),
      ),
    ]);
  }

  Widget buildPlugsIcon(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(2),
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: context.theme.surfaceLayers,
      ),
      child: Icon(
        FontAwesomeIcons.gear,
        size: 12,
      ),
    );
  }
}
