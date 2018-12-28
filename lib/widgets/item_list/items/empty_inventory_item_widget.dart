import 'package:flutter/material.dart';
import 'package:little_light/widgets/item_list/items/inventory_item.widget.dart';


class EmptyInventoryItemWidget extends InventoryItemWidget {
  EmptyInventoryItemWidget() : super(null, null, null);
  

  @override
  Widget build(BuildContext context) {
      return Container(
        margin: EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.1),
          border: Border.all(
            color: Colors.blueGrey.shade900,
            width: 2,
            )
        ),
      );
    }
}
