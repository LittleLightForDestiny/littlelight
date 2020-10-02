import 'dart:math';

import 'package:bungie_api/enums/destiny_item_type.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/item_list/items/armor/armor_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/base/base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/emblem/emblem_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/inventory_item_wrapper.widget.dart';
import 'package:little_light/widgets/item_list/items/subclass/subclass_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/weapon/weapon_inventory_item.widget.dart';
import 'package:little_light/widgets/progress_tabs/pursuit_item/large_pursuit_item.widget.dart';

class QuickSelectItemWrapperWidget extends InventoryItemWrapperWidget {
  QuickSelectItemWrapperWidget(DestinyItemComponent item, int bucketHash,
      {String characterId, Key key})
      : super(item, bucketHash, characterId: characterId, key: key);

  @override
  InventoryItemWrapperWidgetState<QuickSelectItemWrapperWidget> createState() {
    return QuickSelectItemWrapperWidgetState();
  }
}

class QuickSelectItemWrapperWidgetState<T extends QuickSelectItemWrapperWidget>
    extends InventoryItemWrapperWidgetState<QuickSelectItemWrapperWidget> {
  @override
  Widget build(BuildContext context) {
    return buildItem(context);
  }

  @override
  Widget buildFull(BuildContext context) {
    switch (definition.itemType) {
      case DestinyItemType.Subclass:
        {
          return Container(
              height: 96,
              child: SubclassInventoryItemWidget(
                widget.item,
                definition,
                instanceInfo,
                characterId: widget.characterId,
                uniqueId: uniqueId,
              ));
        }
      case DestinyItemType.Weapon:
        {
          var reusablePlugs = ProfileService()
              .getItemReusablePlugs(widget?.item?.itemInstanceId);
          int maxPlugs = 1;
          reusablePlugs?.forEach((key, value) {
            maxPlugs = max(maxPlugs, value.length);
          });
          double height = 96;
          if (maxPlugs > 1) {
            height = 100;
          }
          if (maxPlugs > 2) {
            height = 100 + (maxPlugs - 2) * 20.0;
          }
          return Container(
              height: height,
              child: WeaponInventoryItemWidget(
                widget.item,
                definition,
                instanceInfo,
                characterId: widget.characterId,
                showUnusedPerks: true,
                uniqueId: uniqueId,
                trailing: buildCharacterIcon(context),
              ));
        }

      case DestinyItemType.Armor:
        {
          return Container(
              height: 96,
              child: ArmorInventoryItemWidget(
                widget.item,
                definition,
                instanceInfo,
                characterId: widget.characterId,
                uniqueId: uniqueId,
                trailing: buildCharacterIcon(context),
              ));
        }

      case DestinyItemType.Emblem:
        {
          return Container(
              height: 96,
              child: EmblemInventoryItemWidget(
                widget.item,
                definition,
                instanceInfo,
                characterId: widget.characterId,
                uniqueId: uniqueId,
                trailing: buildCharacterIcon(context),
              ));
        }

      default:
        if (definition?.inventory?.bucketTypeHash == InventoryBucket.pursuits) {
          return LargePursuitItemWidget(
            item: widget.item,
            characterId: widget.characterId,
            selectable: false,
            trailing: buildCharacterIcon(context),
          );
        }
        return Container(
            height: 96,
            child: BaseInventoryItemWidget(
              widget.item,
              definition,
              instanceInfo,
              characterId: widget.characterId,
              uniqueId: uniqueId,
              trailing: buildCharacterIcon(context),
            ));
    }
  }

  Widget buildCharacterIcon(BuildContext context) {
    Widget icon;
    if (widget.characterId == ItemWithOwner.OWNER_VAULT) {
      icon = Image.asset("assets/imgs/vault-icon.jpg");
    } else if (widget.characterId == ItemWithOwner.OWNER_PROFILE) {
      icon = Image.asset("assets/imgs/inventory-icon.jpg");
    } else {
      var character = widget.profile.getCharacter(widget.characterId);
      icon = QueuedNetworkImage(
          imageUrl: BungieApiService.url(character?.emblemPath));
    }

    return Container(
        foregroundDecoration: instanceInfo?.isEquipped == true
            ? BoxDecoration(border: Border.all(width: 2, color: Colors.white))
            : null,
        width: 26,
        height: 26,
        child: icon);
  }
}
