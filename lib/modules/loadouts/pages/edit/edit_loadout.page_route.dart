import 'package:flutter/material.dart';
import 'package:little_light/modules/loadouts/pages/edit/edit_loadout.page.dart';

class EditLoadoutPageRouteArguments {
  String? loadoutID;
  EditLoadoutPageRouteArguments([this.loadoutID]);
}

class EditLoadoutPageRoute extends MaterialPageRoute {
  factory EditLoadoutPageRoute.edit(String loadoutID) {
    return EditLoadoutPageRoute._(EditLoadoutPageRouteArguments(loadoutID));
  }

  factory EditLoadoutPageRoute.create() {
    return EditLoadoutPageRoute._(EditLoadoutPageRouteArguments());
  }

  EditLoadoutPageRoute._(EditLoadoutPageRouteArguments args)
      : super(
          settings: RouteSettings(arguments: args),
          builder: (BuildContext context) => EditLoadoutPage(args),
        );
}
