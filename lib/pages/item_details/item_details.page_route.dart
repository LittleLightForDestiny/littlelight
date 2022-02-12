//@dart=2.12
import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'item_details.page.dart';

class ItemDetailsPageRoute extends MaterialPageRoute {
  ItemDetailsPageRoute({
    Key? key,
    String? characterId,
    DestinyItemComponent? item,
    DestinyInventoryItemDefinition? definition,
    DestinyItemInstanceComponent? instanceInfo,
    bool hideItemManagement = false,
    List<DestinyItemSocketState>? socketStates,
    String? uniqueId,
  })
      : super(
          builder: (context) => ItemDetailsPage(
            key:key,
            characterId:characterId,
            item:item,
            definition:definition,
            instanceInfo: instanceInfo,
            hideItemManagement:hideItemManagement,
            socketStates:socketStates,
            uniqueId:uniqueId,
          ),
        );
}
