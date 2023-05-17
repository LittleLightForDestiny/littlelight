import 'package:flutter/material.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_info.dart';

import 'loadout_item_details.page.dart';

class LoadoutItemDetailsPageRoute extends MaterialPageRoute<Map<int, int>> {
  final LoadoutItemInfo item;

  LoadoutItemDetailsPageRoute(this.item)
      : super(builder: (context) {
          return LoadoutItemDetailsPage(item);
        });
}
