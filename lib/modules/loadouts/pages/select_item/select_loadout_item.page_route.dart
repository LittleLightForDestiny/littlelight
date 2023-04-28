import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';

class SelectLoadoutItemPageRoute extends MaterialPageRoute<DestinyItemInfo?> {
  SelectLoadoutItemPageRoute(
      {int? emblemHash, int? bucketHash, DestinyClass? classType, required List<String> idsToAvoid})
      : super(builder: (BuildContext context) => Container());
}
