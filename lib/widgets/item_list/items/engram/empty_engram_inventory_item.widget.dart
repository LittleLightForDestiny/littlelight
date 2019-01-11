import 'package:flutter/material.dart';
import 'package:little_light/widgets/item_list/items/base/minimal_base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/base/minimal_info_label.mixin.dart';

class EmptyEngramInventoryItemWidget extends MinimalBaseInventoryItemWidget
    with MinimalInfoLabelMixin {
  EmptyEngramInventoryItemWidget({Key key, String characterId})
      : super(null, null, null, characterId:characterId, key:key);

  @override
    Widget itemIconHero(BuildContext context) {
      
      return itemIcon(context);
    }

  @override
  Widget itemIcon(BuildContext context) {
    return Container(padding:EdgeInsets.all(4), child:Image.asset("assets/imgs/engram-placeholder.png"));
  }

  @override
    Widget inkWell(BuildContext context) {
      return null;
    }
}
