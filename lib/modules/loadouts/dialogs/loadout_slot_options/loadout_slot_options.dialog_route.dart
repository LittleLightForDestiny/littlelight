import 'package:flutter/material.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_info.dart';

import 'loadout_slot_options.dialog.dart';

enum LoadoutSlotOptionsResponse { Details, Remove, EditMods }

class LoadoutSlotOptionsDialogRoute extends DialogRoute<LoadoutSlotOptionsResponse?> {
  LoadoutSlotOptionsDialogRoute(BuildContext context, {required LoadoutItemInfo item})
      : super(
          context: context,
          builder: (context) => LoadoutSlotOptionsDialog(),
          settings: RouteSettings(arguments: item),
        );
}
