// @dart=2.9

import 'package:flutter/material.dart';
import 'package:little_light/widgets/item_list/items/base/minimal_base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/base/minimal_info_label.mixin.dart';

class EmptyEngramInventoryItemWidget extends MinimalBaseInventoryItemWidget with MinimalInfoLabelMixin {
  EmptyEngramInventoryItemWidget({
    Key key,
    String characterId,
    @required String uniqueId,
  }) : super(null, null, null, uniqueId: uniqueId, characterId: characterId, key: key);

  @override
  Widget itemIconHero(BuildContext context) {
    return itemIcon(context);
  }

  @override
  Widget primaryStatWidget(BuildContext context) {
    return Container();
  }

  @override
  Widget itemIcon(BuildContext context) {
    return Container(padding: EdgeInsets.all(4), child: Image.asset("assets/imgs/engram-placeholder.png"));
  }
}
