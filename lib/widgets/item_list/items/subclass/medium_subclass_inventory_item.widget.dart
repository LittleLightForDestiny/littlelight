import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_item_talent_grid_component.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie-api/bungie-api.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/item_list/items/base/medium_base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/subclass/subclass_properties.mixin.dart';
import 'package:tinycolor/tinycolor.dart';

class MediumSubclassInventoryItemWidget extends MediumBaseInventoryItemWidget
    with SubclassPropertiesMixin {
  MediumSubclassInventoryItemWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo)
      : super(item, definition, instanceInfo);

  @override
  DestinyItemTalentGridComponent get talentGrid =>
      profile.getTalentGrid(item.itemInstanceId);

  @override
  double get iconSize {
    return 68;
  }

  @override
  background(BuildContext context) {
    var damageTypeColor =
        DestinyData.getDamageTypeColor(definition.talentGrid.hudDamageType);
    BoxDecoration decoration = BoxDecoration(
        gradient:
            RadialGradient(radius: 2, center: Alignment(.7, 0), colors: <Color>[
      TinyColor(damageTypeColor).lighten(15).saturate(50).color,
      damageTypeColor,
      TinyColor(damageTypeColor).darken(40).saturate(50).color,
    ]));
    return Positioned.fill(
        child: Container(
            decoration: decoration,
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              CachedNetworkImage(
                width: 100,
                imageUrl:
                    "${BungieApiService.baseUrl}${definition.secondaryIcon}",
                fit: BoxFit.fitWidth,
                alignment: AlignmentDirectional.topEnd,
              )
            ])));
  }

  @override
  Widget nameBar(BuildContext context) {
    Color damageTypeColor =
        DestinyData.getDamageTypeColor(definition.talentGrid.hudDamageType);
    BoxDecoration decoration = BoxDecoration(
        gradient: LinearGradient(colors: <Color>[
      TinyColor(damageTypeColor).saturate(30).darken(30).color,
      Colors.transparent
    ]));
    return Positioned(
      left: iconSize / 2 + padding,
      right: 0,
      top: 0,
      bottom: 0,
      child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: AlignmentDirectional.centerStart,
              padding: EdgeInsets.only(
                  left: iconSize / 2 + padding * 2,
                  top: padding * 2,
                  bottom: padding * 2,
                  right: padding),
              decoration: decoration,
              child: Text(
                definition.displayProperties.name.toUpperCase(),
                style: TextStyle(
                    fontSize: titleFontSize, fontWeight: FontWeight.bold),
              ),
            ),
          ]),
    );
  }

  @override
  double get padding {
    return 4;
  }
}
