// @dart=2.9

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/primary_stat.widget.dart';
import 'package:little_light/widgets/item_list/items/base/base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/base/item_armor_tier.widget.dart';

class ArmorInventoryItemWidget extends BaseInventoryItemWidget with ProfileConsumer {
  ArmorInventoryItemWidget(
      DestinyItemComponent item, DestinyInventoryItemDefinition definition, DestinyItemInstanceComponent instanceInfo,
      {String characterId, @required String uniqueId, Widget trailing, Key key})
      : super(item, definition, instanceInfo,
            uniqueId: uniqueId, trailing: trailing, characterId: characterId, key: key);

  @override
  Widget primaryStatWidget(BuildContext context) {
    var sockets = item?.itemInstanceId == null ? null : profile.getItemSockets(item?.itemInstanceId);
    var socketCategoryHashes = definition?.sockets?.socketCategories?.map((s) => s.socketCategoryHash);
    var tierCategoryHash =
        socketCategoryHashes?.firstWhere((s) => DestinyData.socketCategoryTierHashes.contains(s), orElse: () => null);
    return Positioned(
        top: titleFontSize + padding * 1.2,
        right: 0,
        child: Container(
            padding: EdgeInsets.all(padding),
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              tierCategoryHash != null
                  ? ItemArmorTierWidget(
                      socketCategoryHash: tierCategoryHash,
                      definition: definition,
                      itemSockets: sockets,
                      iconSize: 24,
                    )
                  : Container(),
              tierCategoryHash != null
                  ? Container(
                      margin: EdgeInsets.symmetric(horizontal: 2),
                      height: 24,
                      width: 1,
                      color: Theme.of(context).colorScheme.onSurface)
                  : Container(),
              PrimaryStatWidget(
                item: item,
                inlinePowerCap: true,
                definition: definition,
                instanceInfo: instanceInfo,
                padding: padding,
                suppressDamageTypeIcon: true,
                suppressLabel: true,
                suppressClassTypeIcon: true,
                fontSize: 24,
              )
            ])));
  }

  @override
  itemIcon(BuildContext context) {
    return Stack(children: [super.itemIcon(context), buildStatTotal(context)]);
  }
}
