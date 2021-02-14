import 'package:bungie_api/enums/destiny_class.dart';
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
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/item_icon/item_icon.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/item_list/items/quick_select_item_wrapper.widget.dart';

typedef void OnRemoveItemFromLoadout(DestinyItemComponent item, bool equipped);
typedef void OnAddItemToLoadout(bool equipped, DestinyClass classType);

class LoadoutSlotWidget extends StatelessWidget {
  final ManifestService manifest = new ManifestService();
  final ProfileService profile = new ProfileService();
  final AuthService auth = new AuthService();
  final DestinyInventoryBucketDefinition bucketDefinition;
  final Map<DestinyClass, DestinyItemComponent> equippedClassItems;
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
        items.addAll([
          DestinyClass.Titan,
          DestinyClass.Hunter,
          DestinyClass.Warlock
        ].map((classType) => buildItemIcon(context,
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
      {DestinyItemComponent item,
      DestinyClass classType,
      bool equipped: true}) {
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
    var isTablet = MediaQueryHelper(context).tabletOrBigger;
    var itemIcon = Container(
        foregroundDecoration: decoration,
        child: Stack(children: [
          Positioned.fill(
              child: item?.itemHash != null
                  ? DefinitionProviderWidget<DestinyInventoryItemDefinition>(
                      item?.itemHash,
                      (def) => ItemIconWidget(item, def, null),
                      key: Key('slot_item_${item?.itemInstanceId}'),
                    )
                  : ManifestImageWidget<DestinyInventoryItemDefinition>(
                      item?.itemHash ?? 1835369552)),
          icon != null ? icon : Container(),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (item != null) {
                  // onRemove(item, equipped);
                  openModal(context, item, equipped);
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
                      item: item,
                      definition: def,
                      instanceInfo: instanceInfo,
                      characterId: null,
                      hideItemManagement: true,
                    ),
                  ),
                );
              },
            ),
          )
        ]));
    if (isTablet) {
      return Container(
          margin: EdgeInsets.only(right: 4),
          width: 64,
          height: 64,
          child: itemIcon);
    }
    return FractionallySizedBox(
        widthFactor: 1 / 6,
        child: Container(
            margin: EdgeInsets.only(right: 4),
            child: AspectRatio(aspectRatio: 1, child: itemIcon)));
  }

  openModal(BuildContext context, DestinyItemComponent item, bool equipped) {
    var ownerId = ProfileService().getItemOwner(item.itemInstanceId);
    var padding = EdgeInsets.all(8).copyWith(bottom: 4);
    var screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 500) {
      padding = padding.copyWith(left: 0, right: 0);
    }
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
              insetPadding: EdgeInsets.all(0),
              child: Container(
                  width: screenWidth + 16,
                  padding: padding,
                  constraints: BoxConstraints(maxWidth: 500),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    QuickSelectItemWrapperWidget(item, null,
                        characterId: ownerId ?? ItemWithOwner.OWNER_VAULT),
                    Row(
                      children: [
                        Expanded(
                            child: ElevatedButton(
                                child: TranslatedTextWidget("Cancel",
                                    uppercase: true,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                })),
                        Container(
                          width: 4,
                        ),
                        Expanded(
                            child: ElevatedButton(
                                child: TranslatedTextWidget("Details",
                                    uppercase: true,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  var def = await manifest.getDefinition<
                                          DestinyInventoryItemDefinition>(
                                      item.itemHash);
                                  var instanceInfo = profile
                                      .getInstanceInfo(item.itemInstanceId);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ItemDetailScreen(
                                        item: item,
                                        definition: def,
                                        instanceInfo: instanceInfo,
                                        characterId: null,
                                        hideItemManagement: true,
                                      ),
                                    ),
                                  );
                                })),
                        Container(width: 4),
                        Expanded(
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Theme.of(context).errorColor),
                                child: TranslatedTextWidget("Remove",
                                    uppercase: true,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  onRemove(item, equipped);
                                  Navigator.of(context).pop();
                                })),
                      ],
                    )
                  ])));
        });
  }
}
