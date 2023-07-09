import 'package:flutter/material.dart';
import 'package:little_light/models/loadout.dart';
import 'edit_loadout.page.dart';

class EditLoadoutPageRoute extends MaterialPageRoute<Loadout> {
  EditLoadoutPageRoute.edit(String loadoutID)
      : super(
          builder: (BuildContext context) => EditLoadoutPage(
            loadoutID: loadoutID,
          ),
        );

  EditLoadoutPageRoute.create()
      : super(
          builder: (BuildContext context) => EditLoadoutPage(),
        );

  EditLoadoutPageRoute.createFromPreset(Loadout preset)
      : super(
          builder: (BuildContext context) => EditLoadoutPage(
            preset: preset,
          ),
        );
}
