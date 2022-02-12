// @dart=2.9

import 'package:flutter/material.dart';
import 'package:little_light/widgets/item_list/items/base/inventory_item.mixin.dart';

mixin MinimalInfoLabelMixin on InventoryItemMixin {
  Widget infoContainer(BuildContext context, Widget child) {
    return Positioned(
        bottom: iconBorderWidth,
        right: iconBorderWidth,
        left: iconBorderWidth,
        child: Container(
            alignment: Alignment.bottomRight,
            child: Container(color: Colors.black.withOpacity(.5), padding: EdgeInsets.all(padding), child: child)));
  }
}
