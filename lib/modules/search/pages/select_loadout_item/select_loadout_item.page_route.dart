import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';

import 'select_loadout_item.page.dart';

class SelectLoadoutItemPageRouteArguments {
  final int bucketHash;
  final DestinyClass? classType;

  final List<String>? idsToAvoid;

  final int? emblemHash;

  SelectLoadoutItemPageRouteArguments({
    required this.bucketHash,
    required this.classType,
    this.idsToAvoid,
    this.emblemHash,
  });

  static SelectLoadoutItemPageRouteArguments? of(BuildContext context) {
    final pageRoute = ModalRoute.of(context);
    if (pageRoute?.settings.arguments is SelectLoadoutItemPageRouteArguments) {
      return pageRoute?.settings.arguments as SelectLoadoutItemPageRouteArguments;
    }
    return null;
  }
}

class SelectLoadoutItemPageRoute extends MaterialPageRoute<InventoryItemInfo?> {
  SelectLoadoutItemPageRoute({
    required int bucketHash,
    required DestinyClass? classType,
    List<String>? idsToAvoid,
    int? emblemHash,
  }) : super(
            settings: RouteSettings(
                arguments: SelectLoadoutItemPageRouteArguments(
              bucketHash: bucketHash,
              classType: classType,
              idsToAvoid: idsToAvoid,
              emblemHash: emblemHash,
            )),
            builder: (context) {
              return SelectLoadoutItemPage();
            });
}
