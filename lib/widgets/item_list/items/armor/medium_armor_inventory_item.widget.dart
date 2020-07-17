import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/primary_stat.widget.dart';
import 'package:little_light/widgets/item_list/items/base/item_armor_tier.widget.dart';
import 'package:little_light/widgets/item_list/items/base/medium_base_inventory_item.widget.dart';

class MediumArmorInventoryItemWidget extends MediumBaseInventoryItemWidget {
  MediumArmorInventoryItemWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition itemDefinition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key,
      @required String uniqueId,
      String characterId})
      : super(item, itemDefinition, instanceInfo,
            key: key, characterId: characterId, uniqueId: uniqueId);

  @override
  Widget primaryStatWidget(BuildContext context) {
    var sockets = item?.itemInstanceId == null
        ? null
        : profile.getItemSockets(item?.itemInstanceId);
    var socketCategoryHashes =
        definition?.sockets?.socketCategories?.map((s) => s.socketCategoryHash);
    var tierCategoryHash = socketCategoryHashes?.firstWhere((s)=>DestinyData.socketCategoryTierHashes.contains(s), orElse:()=>null);
    return Positioned(
        top: titleFontSize + padding*1.5,
        right: 0,
        child: Container(
            padding: EdgeInsets.all(padding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              tierCategoryHash != null ? ItemArmorTierWidget(
                socketCategoryHash: tierCategoryHash,
                definition: definition,
                itemSockets: sockets,
                iconSize: 16,
                suppressIcon:true,
              ) : Container(),
              tierCategoryHash != null ? Container(
                margin:EdgeInsets.symmetric(horizontal:2),
                height: 16, width:1, color:Colors.white) : Container(),
              PrimaryStatWidget(
                definition: definition,
                instanceInfo: instanceInfo,
                padding: padding,
                suppressDamageTypeIcon: true,
                suppressLabel: true,
                suppressClassTypeIcon: true,
                fontSize: 16,
              )
            ])));
  }

  @override
  itemIcon(BuildContext context) {
    
    return Stack(children:[
      super.itemIcon(context),
      buildStatTotal(context)
    ]);
  }
}
