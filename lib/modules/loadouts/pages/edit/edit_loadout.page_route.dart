import 'package:flutter/material.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_index.dart';

import 'edit_loadout.page.dart';

class EditLoadoutPageRouteArguments {
  final String? loadoutID;
  final LoadoutItemIndex? preset;
  EditLoadoutPageRouteArguments({this.loadoutID, this.preset});
}

class EditLoadoutPageRoute extends MaterialPageRoute<LoadoutItemIndex> {
  factory EditLoadoutPageRoute.edit(String loadoutID) {
    return EditLoadoutPageRoute._(EditLoadoutPageRouteArguments(loadoutID: loadoutID));
  }

  factory EditLoadoutPageRoute.create() {
    return EditLoadoutPageRoute._(EditLoadoutPageRouteArguments());
  }

  factory EditLoadoutPageRoute.createFromPreset(LoadoutItemIndex? preset) {
    return EditLoadoutPageRoute._(EditLoadoutPageRouteArguments(preset: preset));
  }

  EditLoadoutPageRoute._(EditLoadoutPageRouteArguments args)
      : super(
          settings: RouteSettings(arguments: args),
          builder: (BuildContext context) => EditLoadoutPage(args),
        );
}
