// @dart=2.12

import 'package:bungie_api/enums/destiny_class.dart';
import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_index.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/item_icon/item_icon.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

typedef OnRemoveItemFromLoadout = void Function(LoadoutIndexItem item, bool equipped);
typedef OnAddItemToLoadout = void Function(DestinyClass? classType, bool equipped);

class LoadoutSlotWidget extends StatelessWidget with ProfileConsumer, ManifestConsumer {
  final DestinyInventoryBucketDefinition? bucketDefinition;
  final OnRemoveItemFromLoadout? onOptions;
  final OnAddItemToLoadout? onAdd;
  final LoadoutIndexSlot slot;
  LoadoutSlotWidget({Key? key, this.bucketDefinition, required this.slot, this.onOptions, this.onAdd})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bucketDef = bucketDefinition;
    if (bucketDef == null) {
      return const AspectRatio(aspectRatio: .3);
    }
    return Column(children: [
      HeaderWidget(
          child: Text(bucketDef.displayProperties?.name?.toUpperCase() ?? "",
              style: const TextStyle(fontWeight: FontWeight.bold))),
      buildSlotBlock(context, headerText: "Equip".translate(context)),
      buildSlotBlock(
        context,
        headerText: "Transfer".translate(context),
        isEquipment: false,
      ),
      Container(height: 8)
    ]);
  }

  Widget buildSlotBlock(BuildContext context, {required String headerText, bool isEquipment = true}) {
    var hasTransferDestination = bucketDefinition?.hasTransferDestination ?? false;
    if (!isEquipment && !hasTransferDestination) return Container();
    return Container(
        padding: const EdgeInsets.all(4),
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[buildBlockTitle(context, headerText), buildItemIcons(context, isEquipment: isEquipment)],
        ));
  }

  Widget buildBlockTitle(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey.shade900,
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildItemIcons(BuildContext context, {bool isEquipment = true}) {
    List<Widget> items = [];
    final hash = bucketDefinition?.hash;
    if (hash == null) return Container();
    if (isEquipment) {
      if (LoadoutItemIndex.isClassSpecificSlot(hash)) {
        items.addAll([DestinyClass.Titan, DestinyClass.Hunter, DestinyClass.Warlock].map(
            (classType) => buildItemIcon(context, item: slot.classSpecificEquipped[classType], classType: classType)));
      } else {
        items.addAll(slot.classSpecificEquipped
            .map((classType, item) => MapEntry(classType, buildItemIcon(context, item: item, classType: classType)))
            .values);
        items.add(buildItemIcon(context, item: slot.genericEquipped));
      }
    } else {
      if (slot.unequipped.length < 9) {
        items.add(buildItemIcon(context, equipped: false));
      }
      items.addAll(slot.unequipped.map((item) => buildItemIcon(context, item: item, equipped: false)));
    }

    return Container(padding: const EdgeInsets.symmetric(vertical: 4), child: Wrap(children: items));
  }

  Widget buildItemIcon(BuildContext context, {LoadoutIndexItem? item, DestinyClass? classType, bool equipped = true}) {
    BoxDecoration? decoration = item?.item != null && bucketDefinition?.hash == InventoryBucket.subclass
        ? null
        : BoxDecoration(border: Border.all(width: 1, color: Colors.grey.shade300));

    IconData? iconData;
    Widget icon;
    if (item?.item == null) {
      icon = Positioned.fill(
          child: Container(
              alignment: Alignment.center,
              child: Icon(iconData ?? Icons.add_circle_outline,
                  size: 26, color: LittleLightTheme.of(context).surfaceLayers.layer3)));
    } else {
      icon = Positioned(
          right: 2,
          bottom: 2,
          child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(color: Theme.of(context).errorColor, borderRadius: BorderRadius.circular(8)),
              child: Icon(iconData ?? Icons.remove_circle_outline,
                  size: 12, color: Theme.of(context).colorScheme.onSurface)));
    }
    var isTablet = MediaQueryHelper(context).tabletOrBigger;
    final itemHash = item?.item?.itemHash;
    var itemIcon = Container(
        foregroundDecoration: decoration,
        child: Stack(children: [
          Positioned.fill(
              child: itemHash != null
                  ? DefinitionProviderWidget<DestinyInventoryItemDefinition>(
                      itemHash,
                      (def) => ItemIconWidget(item?.item, def, null),
                      key: Key('slot_item_${item?.item?.itemInstanceId}'),
                    )
                  : ManifestImageWidget<DestinyInventoryItemDefinition>(1835369552)),
          icon,
          Material(
              color: Colors.transparent,
              child: InkWell(onTap: () {
                if (item?.item != null) {
                  onOptions?.call(item!, equipped);
                } else {
                  onAdd?.call(classType, equipped);
                }
              })),
        ]));
    if (isTablet) {
      return Container(margin: const EdgeInsets.only(right: 4), width: 64, height: 64, child: itemIcon);
    }
    return FractionallySizedBox(
        widthFactor: 1 / 6,
        child: Container(margin: const EdgeInsets.only(right: 4), child: AspectRatio(aspectRatio: 1, child: itemIcon)));
  }
}
