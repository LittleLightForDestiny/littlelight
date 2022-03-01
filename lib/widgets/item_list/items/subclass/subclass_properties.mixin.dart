// @dart=2.9

import 'package:bungie_api/enums/damage_type.dart';
import 'package:bungie_api/models/destiny_item_talent_grid_component.dart';
import 'package:bungie_api/models/destiny_talent_grid_definition.dart';
import 'package:bungie_api/models/destiny_talent_node_category.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/item_icon/subclass_icon.widget.dart';
import 'package:little_light/widgets/item_list/items/base/inventory_item.mixin.dart';
import 'package:little_light/widgets/item_list/items/subclass/subclass_image.widget.dart';
import 'package:tinycolor2/tinycolor2.dart';

mixin SubclassPropertiesMixin on InventoryItemMixin {
  DestinyItemTalentGridComponent get talentGrid;

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
              talentGrid != null
                  ? DefinitionProviderWidget<DestinyTalentGridDefinition>(talentGrid.talentGridHash, (def) {
                      var text = extractTalentGridName(def);
                      if (text.length > 0) {
                        return Text(text,
                            style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w300, fontSize: 12));
                      }
                      return Container();
                    })
                  : Container()
            ],
          ),
        ),
      ]),
    );
  }

  DestinyTalentNodeCategory extractTalentGridNodeCategory(DestinyTalentGridDefinition talentGridDef) {
    Iterable<int> activatedNodes = talentGrid?.nodes?.where((node) => node.isActivated)?.map((node) => node.nodeIndex);
    Iterable<DestinyTalentNodeCategory> selectedSkills = talentGridDef?.nodeCategories?.where((category) {
      var overlapping = category.nodeHashes.where((nodeHash) => activatedNodes?.contains(nodeHash) ?? false);
      return overlapping.length > 0;
    })?.toList();
    DestinyTalentNodeCategory subclassPath =
        selectedSkills?.firstWhere((nodeDef) => nodeDef.isLoreDriven, orElse: () => null);
    return subclassPath;
  }

  Widget buildTalentGridImage() {
    return SubClassImageWidget(item, definition, instanceInfo);
  }

  String extractTalentGridName(DestinyTalentGridDefinition talentGridDefinition) {
    DestinyTalentNodeCategory cat = extractTalentGridNodeCategory(talentGridDefinition);
    return cat?.displayProperties?.name ?? "";
  }

  @override
  Widget categoryName(BuildContext context) {
    return null;
  }

  startBgColor(BuildContext context) {
    var damageTypeColor = definition.talentGrid.hudDamageType?.getColorLayer(context)?.layer0;
    return TinyColor(damageTypeColor).lighten(15).saturate(50).color;
  }

  endBgColor(BuildContext context) {
    final damageTypeColor = definition.talentGrid.hudDamageType?.getColorLayer(context)?.layer0;
    return TinyColor(damageTypeColor).darken(25).desaturate(30).color;
    ;
  }

  @override
  background(BuildContext context) {
    var damageTypeColor = definition.talentGrid.hudDamageType?.getColorLayer(context)?.layer0;
    BoxDecoration decoration = BoxDecoration(
        gradient: RadialGradient(
            radius: 3,
            center: Alignment(definition?.talentGrid?.hudDamageType == DamageType.Stasis ? -1 : .7, 0),
            colors: <Color>[
          startBgColor(context),
          damageTypeColor,
          endBgColor(context),
        ]));
    return Positioned.fill(
        child: Container(alignment: Alignment.centerRight, decoration: decoration, child: buildTalentGridImage()));
  }
}
