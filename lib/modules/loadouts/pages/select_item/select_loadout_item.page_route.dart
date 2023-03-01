import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/modules/loadouts/pages/select_item/select_loadout_item.view.dart';
import 'package:little_light/utils/item_with_owner.dart';

class SelectLoadoutItemPageRoute extends MaterialPageRoute<ItemWithOwner?> {
  SelectLoadoutItemPageRoute(
      {int? emblemHash,
      int? bucketHash,
      DestinyClass? classType,
      required List<String> idsToAvoid})
      : super(
          builder: (BuildContext context) => SelectLoadoutItemView(
            context,
            emblemHash: emblemHash,
            bucketHash: bucketHash,
            classType: classType,
            idsToAvoid: idsToAvoid,
          ),
        );
}
