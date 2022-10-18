import 'package:flutter/material.dart';

import 'edit_loadout_item_mods.page.dart';

class EditLoadoutItemModsPageArguments {
  final String itemInstanceID;
  final Map<int, int>? plugHashes;
  final int? emblemHash;

  EditLoadoutItemModsPageArguments(
    this.itemInstanceID, {
    this.plugHashes,
    this.emblemHash,
  });
}

class EditLoadoutItemModsPageRoute extends MaterialPageRoute<Map<int, int>?> {
  factory EditLoadoutItemModsPageRoute(
    String itemInstanceID, {
    Map<int, int>? plugHashes,
    int? emblemHash,
  }) =>
      EditLoadoutItemModsPageRoute._(EditLoadoutItemModsPageArguments(
        itemInstanceID,
        plugHashes: plugHashes,
        emblemHash: emblemHash,
      ));

  EditLoadoutItemModsPageRoute._(EditLoadoutItemModsPageArguments args)
      : super(
          builder: (context) => EditLoadoutItemModsPage(args),
        );
}
