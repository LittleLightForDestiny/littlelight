import 'package:flutter/material.dart';

import 'edit_loadout_item_mods.page.dart';

class EditLoadoutItemModsPageArguments {
  final String itemInstanceID;
  final Map<int, int>? plugHashes;

  EditLoadoutItemModsPageArguments(this.itemInstanceID, [this.plugHashes]);
}

class EditLoadoutItemModsPageRoute extends MaterialPageRoute {
  factory EditLoadoutItemModsPageRoute(String itemInstanceID, [Map<int, int>? plugHashes]) =>
      EditLoadoutItemModsPageRoute._(EditLoadoutItemModsPageArguments(itemInstanceID, plugHashes));

  EditLoadoutItemModsPageRoute._(EditLoadoutItemModsPageArguments args)
      : super(
          builder: (context) => EditLoadoutItemModsPage(args),
        );
}
