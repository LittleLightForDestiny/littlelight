import 'package:flutter/material.dart';
import 'package:little_light/models/loadout.dart';
import 'edit_loadout.page.dart';

class EditLoadoutPageRouteArguments {
  final String? loadoutID;
  EditLoadoutPageRouteArguments({this.loadoutID});
}

class EditLoadoutPageRoute extends MaterialPageRoute<Loadout> {
  factory EditLoadoutPageRoute.edit(String loadoutID) {
    return EditLoadoutPageRoute._(EditLoadoutPageRouteArguments(loadoutID: loadoutID));
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
