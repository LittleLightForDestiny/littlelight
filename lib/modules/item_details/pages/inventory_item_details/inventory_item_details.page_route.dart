import 'package:flutter/material.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';
import 'package:little_light/modules/item_details/pages/inventory_item_details/inventory_item_details.page.dart';

class InventoryItemDetailsPageRoute extends MaterialPageRoute {
  final InventoryItemInfo item;

  InventoryItemDetailsPageRoute(this.item)
      : super(builder: (context) {
          return InventoryItemDetailsPage(item);
        });
}
