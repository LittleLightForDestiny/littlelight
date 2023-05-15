import 'package:flutter/material.dart';
import 'package:little_light/modules/item_details/pages/loadout_item_details/loadout_item_details.page.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_info.dart';

class LoadoutItemDetailsPageRoute extends MaterialPageRoute<Map<int, int>> {
  final LoadoutItemInfo item;

  LoadoutItemDetailsPageRoute(this.item)
      : super(builder: (context) {
          return LoadoutItemDetailsPage(item);
        });
}
