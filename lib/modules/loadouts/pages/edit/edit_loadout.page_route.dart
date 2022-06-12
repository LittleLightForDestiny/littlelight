import 'package:flutter/material.dart';
import 'package:little_light/modules/loadouts/pages/edit/edit_loadout.page.dart';

class EditLoadoutPageRouteArguments {
  String? loadoutID;
  EditLoadoutPageRouteArguments(this.loadoutID);
}

class EditLoadoutPageRoute extends MaterialPageRoute {
  EditLoadoutPageRoute({required String loadoutID})
      : super(
          settings: RouteSettings(arguments: EditLoadoutPageRouteArguments(loadoutID)),
          builder: (BuildContext context) => EditLoadoutPage(),
        );
}

class CreateLoadoutPageRoute extends MaterialPageRoute {
  CreateLoadoutPageRoute()
      : super(
          builder: (BuildContext context) => EditLoadoutPage(),
        );
}
