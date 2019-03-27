import 'dart:math';

import 'package:bungie_api/enums/tier_type_enum.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/widgets/common/destiny_item.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';


class ItemDetailDuplicatesWidget extends DestinyItemWidget {
  final int selectedPerkHash;
  final Map<int, int> selectedPerkHashes;
  final Map<int, DestinyInventoryItemDefinition> plugDefinitions;
  final List<ItemWithOwner> duplicates;

  ItemDetailDuplicatesWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key,
      duplicates
      })
      : super(item, definition, instanceInfo, key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          HeaderWidget(
              child: Container(
            alignment: Alignment.centerLeft,
            child: TranslatedTextWidget(
              "Duplicates",
              uppercase: true,
              textAlign: TextAlign.left,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          )),
        ],
      ),
    );
  }
}
