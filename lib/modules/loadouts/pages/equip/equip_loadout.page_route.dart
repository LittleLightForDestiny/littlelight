import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/loadouts/loadout_item_index.dart';
import 'equip_loadout.page.dart';

class EquipLoadoutPageRoute extends MaterialPageRoute<LoadoutItemIndex> {
  EquipLoadoutPageRoute(String loadoutID)
      : super(
          builder: (BuildContext context) => EquipLoadoutPage(loadoutID),
        );
}
