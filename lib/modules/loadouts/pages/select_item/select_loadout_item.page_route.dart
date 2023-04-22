import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/item_with_owner.dart';

class SelectLoadoutItemPageRoute extends MaterialPageRoute<ItemWithOwner?> {
  SelectLoadoutItemPageRoute(
      {int? emblemHash, int? bucketHash, DestinyClass? classType, required List<String> idsToAvoid})
      : super(builder: (BuildContext context) => Container());
}
