import 'package:flutter/material.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_index.dart';

import 'equip_loadout.page.dart';

class EquipLoadoutPageRouteArguments {
  String? loadoutID;
  EquipLoadoutPageRouteArguments(this.loadoutID);
}

class EquipLoadoutPageRoute extends MaterialPageRoute<LoadoutItemIndex> {
  factory EquipLoadoutPageRoute(String loadoutID) {
    return EquipLoadoutPageRoute._(EquipLoadoutPageRouteArguments(loadoutID));
  }

  EquipLoadoutPageRoute._(EquipLoadoutPageRouteArguments args)
      : super(
          settings: RouteSettings(arguments: args),
          builder: (BuildContext context) => EquipLoadoutPage(args),
        );
}
