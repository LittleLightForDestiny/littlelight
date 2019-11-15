import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/screens/item_detail.screen.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

typedef void OnRemoveItemFromLoadout(DestinyItemComponent item, bool equipped);
typedef void OnAddItemToLoadout(bool equipped, int classType);

class LoadoutSlotWidget extends StatelessWidget {
  final ManifestService manifest = new ManifestService();
  final ProfileService profile = new ProfileService();
  final AuthService auth = new AuthService();
  final DestinyInventoryBucketDefinition bucketDefinition;
  final Map<int, DestinyItemComponent> equippedClassItems;
  final DestinyItemComponent equippedGenericItem;
  final List<DestinyItemComponent> unequippedItems;
  final OnRemoveItemFromLoadout onRemove;
  final OnAddItemToLoadout onAdd;
  LoadoutSlotWidget(
      {Key key,
      this.bucketDefinition,
      this.equippedClassItems,
      this.equippedGenericItem,
      this.unequippedItems,
      this.onRemove,
      this.onAdd})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (bucketDefinition == null) {
      return AspectRatio(aspectRatio: .3);
    }
    return Column(children: [
      HeaderWidget(
          child: Text(bucketDefinition.displayProperties.name.toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.bold))),
      buildSlotBlock(context, headerText: "Equip"),
      buildSlotBlock(
        context,
        headerText: "Transfer",
        isEquipment: false,
      ),
      Container(height: 8)
    ]);
  }

  Widget buildSlotBlock(BuildContext context,
      {String headerText, bool isEquipment = true}) {
    if (!isEquipment && !bucketDefinition.hasTransferDestination)
      return Container();
    return Container(
        padding: EdgeInsets.all(4),
        color: Colors.blueGrey.shade800,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            buildBlockTitle(context, headerText),
            buildItemIcons(context, isEquipment: isEquipment)
          ],
        ));
  }

  Widget buildBlockTitle(BuildContext context, String text) {
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.grey.shade900,
      child: TranslatedTextWidget(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
        uppercase: true,
      ),
    );
  }

  buildItemIcons(BuildContext context, {bool isEquipment = true}) {
    List<Widget> items = [];
    if (isEquipment) {
      if (LoadoutItemIndex.classBucketHashes.contains(bucketDefinition.hash)) {
        items.addAll([0, 1, 2].map((classType) => buildItemIcon(context,
            item: equippedClassItems[classType], classType: classType)));
      } else {
        items.addAll(equippedClassItems
            .map((classType, item) => MapEntry(
                classType,
                item == null
                    ? null
                    : buildItemIcon(context, item: item, classType: classType)))
            .values
            .where((i) => i != null));

        items.add(buildItemIcon(context, item: equippedGenericItem));
      }
    } else {
      if ((unequippedItems?.length ?? 0) < 9) {
        items.add(buildItemIcon(context, equipped: false));
      }
      if (unequippedItems != null) {
        items.addAll(unequippedItems.map(
            (item) => buildItemIcon(context, item: item, equipped: false)));
      }
    }

    return Container(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Wrap(children: items));
  }

  Widget buildItemIcon(BuildContext context,
      {DestinyItemComponent item, int classType, bool equipped: true}) {
    BoxDecoration decoration =
        item != null && bucketDefinition.hash == InventoryBucket.subclass
            ? null
            : BoxDecoration(
                border: Border.all(width: 1, color: Colors.grey.shade300));

    IconData iconData;
    Widget icon;
    if (classType != null) {
      iconData = DestinyData.getClassIcon(classType);
    }
    if (item == null) {
      icon = Positioned.fill(
          child: Container(
              alignment: Alignment.center,
              child: Icon(iconData ?? Icons.add_circle_outline,
                  size: 26, color: Colors.blueGrey.shade200)));
    } else {
      icon = Positioned(
          right: 2,
          bottom: 2,
          child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                  color: Theme.of(context).errorColor,
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(iconData ?? Icons.remove_circle_outline,
                  size: 12, color: Colors.white)));
    }
    return FractionallySizedBox(
        widthFactor: 1 / 6,
        child: Container(
            margin: EdgeInsets.only(right: 4),
            child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                    foregroundDecoration: decoration,
                    child: Stack(children: [
                      Positioned.fill(
                          child: ManifestImageWidget<
                              DestinyInventoryItemDefinition>(
                        item?.itemHash ?? 1835369552,
                        key: Key('slot_item_${item?.itemInstanceId}'),
                      )),
                      icon != null ? icon : Container(),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (item != null) {
                              onRemove(item, equipped);
                            } else {
                              onAdd(equipped, classType);
                            }
                          },
                          onLongPress: () async {
                            if (item == null) {
                              return;
                            }
                            var def = await manifest.getDefinition<
                                DestinyInventoryItemDefinition>(item.itemHash);
                            var instanceInfo = profile.getInstanceInfo(item.itemInstanceId);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ItemDetailScreen(
                                  item,
                                  def,
                                  instanceInfo,
                                  characterId: null,
                                  isLoadoutItemDetails: true,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    ])))));
  }
}
