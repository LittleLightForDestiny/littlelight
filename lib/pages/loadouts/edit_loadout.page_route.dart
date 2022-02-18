import 'package:flutter/material.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/providers/loadouts/loadout.provider.dart';
import 'package:provider/provider.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'edit_loadout.page.dart';

extension on Loadout {
  Loadout clone() => Loadout.fromJson(this.toJson());
}

class EditLoadoutPageRoute extends MaterialPageRoute {
  EditLoadoutPageRoute({required Loadout loadout})
      : super(
          builder: (BuildContext context) => _builder(context, loadout),
        );
}

class CreateLoadoutPageRoute extends MaterialPageRoute {
  CreateLoadoutPageRoute()
      : super(
          builder: (BuildContext context) => _builder(context),
        );
}

_builder(BuildContext context, [Loadout? loadout]) => MultiProvider(
      providers: [
        ChangeNotifierProvider<LoadoutProvider>(create: ((context) => LoadoutProvider(loadout?.clone() ?? Loadout()))),
      ],
      child: EditLoadoutPage(),
    );
