// @dart=2.9

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/widgets/item_list/items/base/base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/subclass/subclass_properties.mixin.dart';

class SubclassInventoryItemWidget extends BaseInventoryItemWidget
    with SubclassPropertiesMixin, ProfileConsumer {
  SubclassInventoryItemWidget(
    DestinyItemComponent item,
    DestinyInventoryItemDefinition definition,
    DestinyItemInstanceComponent instanceInfo, {
    @required String characterId,
    Key key,
    @required String uniqueId,
  }) : super(
          item,
          definition,
          instanceInfo,
          characterId: characterId,
          key: key,
          uniqueId: uniqueId,
        );

  @override
  Widget primaryStatWidget(BuildContext context) {
    return Container();
  }
}
