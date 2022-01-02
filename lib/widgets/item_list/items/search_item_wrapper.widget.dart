import 'dart:async';

import 'package:bungie_api/enums/destiny_item_type.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/selection/selection.service.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/item_list/items/armor/armor_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/base/base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/emblem/emblem_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/inventory_item_wrapper.widget.dart';
import 'package:little_light/widgets/item_list/items/subclass/subclass_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/weapon/weapon_inventory_item.widget.dart';
import 'package:little_light/widgets/progress_tabs/pursuit_item/large_pursuit_item.widget.dart';

class SearchItemWrapperWidget extends InventoryItemWrapperWidget {
  SearchItemWrapperWidget(DestinyItemComponent item, int bucketHash,
      {String characterId, Key key})
      : super(item, bucketHash, characterId: characterId, key: key);

  @override
  InventoryItemWrapperWidgetState<SearchItemWrapperWidget> createState() {
    return SearchItemWrapperWidgetState();
  }
}

class SearchItemWrapperWidgetState<T extends SearchItemWrapperWidget>
    extends InventoryItemWrapperWidgetState<SearchItemWrapperWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: Theme.of(context).colorScheme.primary)),
        child: Stack(children: [
          Positioned.fill(child: buildItem(context)),
          selected
              ? Container(
                  foregroundDecoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).selectedRowColor, width: 2)),
                )
              : Container(),
          buildTapHandler(context)
        ]));
  }

  @override
  Widget buildFull(BuildContext context) {
    switch (definition.itemType) {
      case DestinyItemType.Subclass:
        {
          return SubclassInventoryItemWidget(
            widget.item,
            definition,
            instanceInfo,
            characterId: widget.characterId,
            uniqueId: uniqueId,
          );
        }
      case DestinyItemType.Weapon:
        {
          return WeaponInventoryItemWidget(
            widget.item,
            definition,
            instanceInfo,
            characterId: widget.characterId,
            uniqueId: uniqueId,
            trailing: buildCharacterIcon(context),
          );
        }

      case DestinyItemType.Armor:
        {
          return ArmorInventoryItemWidget(
            widget.item,
            definition,
            instanceInfo,
            characterId: widget.characterId,
            uniqueId: uniqueId,
            trailing: buildCharacterIcon(context),
          );
        }

      case DestinyItemType.Emblem:
        {
          return EmblemInventoryItemWidget(
            widget.item,
            definition,
            instanceInfo,
            characterId: widget.characterId,
            uniqueId: uniqueId,
            trailing: buildCharacterIcon(context),
          );
        }

      default:
        if (InventoryBucket.pursuitBucketHashes
            .contains(widget?.item?.bucketHash)) {
          return LargePursuitItemWidget(
            characterId: widget.characterId,
            trailing: buildCharacterIcon(context),
            item: widget.item,
          );
        }
        return BaseInventoryItemWidget(
          widget.item,
          definition,
          instanceInfo,
          characterId: widget.characterId,
          uniqueId: uniqueId,
          trailing: buildCharacterIcon(context),
        );
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
          imageUrl: BungieApiService.url(character.emblemPath));
    }

    return Container(
        foregroundDecoration: instanceInfo?.isEquipped == true
            ? BoxDecoration(border: Border.all(width: 2, color: Theme.of(context).colorScheme.onSurface))
            : null,
        width: 26,
        height: 26,
        child: icon);
  }

  @override
  void onLongPress(context) {
    SelectionService().activateMultiSelect();
    SelectionService().addItem(ItemWithOwner(widget.item, widget.characterId));
    setState(() {});

    StreamSubscription<List<ItemWithOwner>> sub;
    sub = SelectionService().broadcaster.listen((selectedItems) {
      if (!mounted) {
        sub.cancel();
        return;
      }
      setState(() {});
      if (!selected) {
        sub.cancel();
      }
    });
  }
}
