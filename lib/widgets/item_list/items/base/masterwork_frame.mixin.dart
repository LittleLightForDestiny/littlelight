import 'package:flutter/material.dart';
import 'package:little_light/services/bungie-api/bungie-api.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/item_list/items/base/inventory_item.mixin.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bungie_api/enums/item_state_enum.dart';
import 'package:bungie_api/enums/tier_type_enum.dart';
import 'package:shimmer/shimmer.dart';

mixin MasterworkFrameMixin on InventoryItemMixin {

  @override
  Widget borderedIcon(BuildContext context) {
    if(item.state & ItemState.Masterwork != ItemState.Masterwork){
      return super.borderedIcon(context);
    }
    return Stack(children: [
      CachedNetworkImage(
        imageUrl:
            "${BungieApiService.baseUrl}${definition.displayProperties.icon}",
        fit: BoxFit.fill,
        placeholder: itemIconPlaceholder(context),
      ),
      Positioned.fill(child: getMasterworkOutline()),
      Positioned.fill(child:
      Shimmer.fromColors(
        baseColor: Colors.amber.withOpacity(.2),
        highlightColor: Colors.amber.shade100,
        child:getMasterworkOutline(),
        period: Duration(seconds: 5),
      ))

    ]);
  }

  Image getMasterworkOutline(){
    if(definition.inventory.tierType == TierType.Exotic){
      return Image.asset("assets/imgs/masterwork-outline-exotic.png");
    }
    return Image.asset("assets/imgs/masterwork-outline.png");
  }

  @override
  BoxDecoration nameBarBoxDecoration(){
    if(item.state & ItemState.Masterwork != ItemState.Masterwork){
      return super.nameBarBoxDecoration();
    }
    return BoxDecoration(color: DestinyData.getTierColor(definition.inventory.tierType),
    image:DecorationImage(
      repeat: ImageRepeat.repeatX,
      alignment: Alignment.topCenter,
      image:getMasterWorkTopOverlay()
      ));
  }

  ExactAssetImage getMasterWorkTopOverlay(){
    if(definition.inventory.tierType == TierType.Exotic){
      return ExactAssetImage("assets/imgs/masterwork-top-exotic.png");
    }
    return ExactAssetImage("assets/imgs/masterwork-top.png");
  }
}
