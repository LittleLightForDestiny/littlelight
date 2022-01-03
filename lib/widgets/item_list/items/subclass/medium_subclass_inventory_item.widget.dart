import 'package:bungie_api/enums/damage_type.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_item_talent_grid_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/item_list/items/base/medium_base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/subclass/subclass_properties.mixin.dart';

class MediumSubclassInventoryItemWidget extends MediumBaseInventoryItemWidget
    with SubclassPropertiesMixin, ProfileConsumer {
  MediumSubclassInventoryItemWidget(
    DestinyItemComponent item,
    DestinyInventoryItemDefinition definition,
    DestinyItemInstanceComponent instanceInfo, {
    @required String characterId,
    Key key,
    @required String uniqueId,
  }) : super(item, definition, instanceInfo,
            characterId: characterId, key: key, uniqueId: uniqueId);

  @override
  DestinyItemTalentGridComponent get talentGrid =>
      profile.getTalentGrid(item?.itemInstanceId);

  @override
  double get iconSize {
    return 68;
  }

  @override
  background(BuildContext context) {
    var damageTypeColor =
        DestinyData.getDamageTypeColor(definition?.talentGrid?.hudDamageType);
    BoxDecoration decoration = BoxDecoration(
        gradient: RadialGradient(
            radius: 2,
            center: Alignment(
                definition?.talentGrid?.hudDamageType == DamageType.Stasis
                    ? -2
                    : 2,
                0),
            colors: <Color>[
          startBgColor(),
          damageTypeColor,
          endBgColor(),
        ]));
    return Positioned.fill(
        child: Container(
            alignment: Alignment.centerRight,
            decoration: decoration,
            child: buildTalentGridImage()));
  }

  @override
  Widget positionedNameBar(BuildContext context) {
    return Container();
  }

  @override
  double get padding {
    return 4;
  }

  @override
  Widget perksWidget(BuildContext context) {
    return Container();
  }

  @override
  Widget modsWidget(BuildContext context) {
    return Container();
  }

  @override
  Widget primaryStatWidget(BuildContext context) {
    return Container();
  }
}
