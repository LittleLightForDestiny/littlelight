// @dart=2.9

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/item_icon/subclass_icon.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/item_list/items/base/inventory_item.mixin.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tinycolor2/tinycolor2.dart';

mixin SubclassPropertiesMixin on InventoryItemMixin {
  @override
  Widget positionedIcon(BuildContext context) {
    return Positioned(
        top: 0, left: 0, width: iconSize + padding * 2, height: iconSize + padding * 2, child: itemIconHero(context));
  }

  Widget itemIcon(BuildContext context) {
    return SubclassIconWidget(item, definition, instanceInfo);
  }

  @override
  Widget positionedNameBar(BuildContext context) {
    Color damageTypeColor = definition.talentGrid.hudDamageType?.getColorLayer(context)?.layer0;
    BoxDecoration decoration = BoxDecoration(
        gradient: LinearGradient(
            colors: <Color>[TinyColor(damageTypeColor).saturate(30).darken(30).color, Colors.transparent]));
    return Positioned(
      left: iconSize / 2 + padding,
      right: 0,
      top: 0,
      bottom: 0,
      child: Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          alignment: AlignmentDirectional.centerStart,
          padding: EdgeInsets.symmetric(horizontal: iconSize / 2 + padding * 2, vertical: padding),
          decoration: decoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(definition.displayProperties.name.toUpperCase(),
                  style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ]),
    );
  }

  @override
  Widget categoryName(BuildContext context) {
    return null;
  }

  Color startBgColor(BuildContext context) {
    var damageTypeColor = definition.talentGrid.hudDamageType?.getColorLayer(context)?.layer0;
    return TinyColor(damageTypeColor).lighten(15).saturate(50).color;
  }

  Color endBgColor(BuildContext context) {
    final damageTypeColor = definition.talentGrid.hudDamageType?.getColorLayer(context)?.layer0;
    return TinyColor(damageTypeColor).darken(25).desaturate(30).color;
  }

  @override
  background(BuildContext context) {
    BoxDecoration decoration = BoxDecoration(
        gradient: RadialGradient(
      radius: 2,
      center: Alignment(1, 0),
      colors: <Color>[
        startBgColor(context).withOpacity(.1),
        Colors.transparent,
        endBgColor(context),
      ],
      stops: [0, .3, .9],
    ));
    return Positioned.fill(
        child: Container(
            decoration: decoration,
            foregroundDecoration: decoration,
            child: ManifestImageWidget<DestinyInventoryItemDefinition>(
              item.itemHash,
              alignment: Alignment.centerRight,
              urlExtractor: (def) => def.screenshot,
              placeholder: Shimmer.fromColors(
                child: Container(color: Colors.white),
                baseColor: endBgColor(context),
                highlightColor: startBgColor(context),
              ),
            )));
  }
}
