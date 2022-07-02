import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:flutter/material.dart';

import 'loadout_slot_options.dialog.dart';

enum LoadoutSlotOptionsResponse { Details, Remove, EditMods }

class LoadoutSlotOptionsDialogRoute extends DialogRoute<LoadoutSlotOptionsResponse?> {
  LoadoutSlotOptionsDialogRoute(BuildContext context, {required DestinyItemComponent item})
      : super(
          context: context,
          builder: (context) => LoadoutSlotOptionsDialog(),
          settings: RouteSettings(arguments: item),
        );
}
