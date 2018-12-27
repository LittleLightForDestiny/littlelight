import 'package:bungie_api/enums/damage_type_enum.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_item_talent_grid_component.dart';
import 'package:bungie_api/models/destiny_stat.dart';
import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:bungie_api/models/destiny_talent_grid_definition.dart';
import 'package:bungie_api/models/destiny_talent_node_category.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie-api/bungie-api.service.dart';
import 'package:little_light/services/bungie-api/enums/inventory-bucket-hash.enum.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/utils/shimmer-helper.dart';
import 'package:tinycolor/tinycolor.dart';

class InventoryItemWidget extends StatefulWidget {
  final DestinyItemComponent item;
  final manifest = new ManifestService();
  final profile = new ProfileService();
  InventoryItemWidget(this.item);
  @override
  InventoryItemWidgetState createState() => new InventoryItemWidgetState();
}

class InventoryItemWidgetState extends State<InventoryItemWidget> {
  DestinyInventoryItemDefinition itemDefinition;
  DestinyItemInstanceComponent instanceInfo;

  @override
  void initState() {
    itemDefinition = widget.manifest.getItemDefinition(widget.item.itemHash);
    instanceInfo = widget.profile.profile.itemComponents.instances
        .data[widget.item.itemInstanceId];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        background(context),
        nameBar(context),
        categoryName(context),
        primaryStat(context),
        itemIcon(context)
      ].where((w) => w != null).toList(),
    );
  }

  Widget itemIcon(BuildContext context) {
    if (widget.item.bucketHash == InventoryBucket.subclass) {
      return Positioned(
          top: 0,
          left: 0,
          width: iconSize + padding * 2,
          height: iconSize + padding * 2,
          child: CachedNetworkImage(
              imageUrl:
                  "${BungieApiService.baseUrl}${itemDefinition.displayProperties.icon}",
              fit: BoxFit.fill,
              placeholder: ShimmerHelper.getDefaultShimmer(
                context,
                child: Icon(DestinyData.getClassIcon(itemDefinition.classType),
                    size: 60),
              )));
    }
    return Positioned(
        top: padding,
        left: padding,
        width: iconSize,
        height: iconSize,
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 2)),
            child: CachedNetworkImage(
              imageUrl:
                  "${BungieApiService.baseUrl}${itemDefinition.displayProperties.icon}",
              fit: BoxFit.fill,
              placeholder: ShimmerHelper.getDefaultShimmer(context),
            )));
  }

  Widget primaryStat(BuildContext context) {
    DestinyStat stat = instanceInfo.primaryStat;
    if (stat == null) return null;
    Color damageTypeColor =
        DestinyData.getDamageTypeTextColor(instanceInfo.damageType);
    DestinyStatDefinition statDefinition =
        widget.manifest.getStatDefinition(stat.statHash);
    return Positioned(
        bottom: 0,
        right: 0,
        child: Container(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                  Padding(padding: EdgeInsets.only(right: padding),
                  child:Icon(
                    DestinyData.getAmmoTypeIcon(itemDefinition.equippingBlock.ammoType),
                    color: DestinyData.getAmmoTypeColor(itemDefinition.equippingBlock.ammoType),
                    size:18
                  )
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: padding/2),
                      child: Icon(
                          DestinyData.getDamageTypeIcon(
                              instanceInfo.damageType),
                          size: 18,
                          color: damageTypeColor)),
                  Text(
                    "${stat.value}",
                    style: TextStyle(
                        color: damageTypeColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 26),
                  ),
                ]),
                Text(
                  statDefinition.displayProperties.name.toUpperCase(),
                  style: TextStyle(
                      color: damageTypeColor,
                      fontWeight: FontWeight.w100,
                      fontSize: 16),
                )
              ],
            )));
  }

  Widget categoryName(BuildContext context) {
    if (widget.item.bucketHash == InventoryBucket.subclass) {
      return null;
    }

    return Positioned(
        left: padding * 2 + iconSize,
        top: padding * 3 + titleFontSize,
        child: Text(
          itemDefinition.itemTypeDisplayName,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w100),
        ));
  }

  Widget nameBar(BuildContext context) {
    if (widget.item.bucketHash == InventoryBucket.subclass) {
      Color damageTypeColor = DestinyData.getDamageTypeColor(
          itemDefinition.talentGrid.hudDamageType);
      DestinyItemTalentGridComponent talentGrid = widget.profile.profile
          .itemComponents.talentGrids.data[widget.item.itemInstanceId];
      DestinyTalentGridDefinition gridDef =
          widget.manifest.getTalentGridDefinition(talentGrid.talentGridHash);
      Iterable<int> activatedNodes = talentGrid.nodes
          .where((node) => node.isActivated)
          .map((node) => node.nodeIndex);
      Iterable<DestinyTalentNodeCategory> selectedSkills =
          gridDef.nodeCategories.where((category) {
        var overlapping = category.nodeHashes
            .where((nodeHash) => activatedNodes.contains(nodeHash));
        return overlapping.length > 0;
      }).toList();
      DestinyTalentNodeCategory subclassPath =
          selectedSkills.firstWhere((nodeDef) => nodeDef.isLoreDriven);
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
                padding: EdgeInsets.symmetric(
                    horizontal: iconSize / 2 + padding * 2, vertical: padding),
                decoration: decoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(itemDefinition.displayProperties.name.toUpperCase(),
                        style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold)),
                    Text(subclassPath.displayProperties.name,
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w100,
                            fontSize: 12))
                  ],
                ),
              ),
            ]),
      );
    }
    return Positioned(
        left: 0,
        right: 0,
        child: Container(
            padding: EdgeInsets.only(
                top: padding, bottom: padding, left: iconSize + padding * 2),
            color: DestinyData.getTierColor(itemDefinition.inventory.tierType),
            child: Text(
              itemDefinition.displayProperties.name.toUpperCase(),
              style: TextStyle(
                fontSize: titleFontSize,
                color: DestinyData.getTierTextColor(
                    itemDefinition.inventory.tierType),
                fontWeight: FontWeight.bold,
              ),
            )));
  }

  background(BuildContext context) {
    if (widget.item.bucketHash == InventoryBucket.subclass) {
      var damageTypeColor = DestinyData.getDamageTypeColor(
          itemDefinition.talentGrid.hudDamageType);
      BoxDecoration decoration = BoxDecoration(
          gradient: RadialGradient(
              radius: 3,
              center: Alignment(.7, 0),
              colors: <Color>[
            TinyColor(damageTypeColor).lighten(15).saturate(50).color,
            damageTypeColor,
            TinyColor(damageTypeColor).darken(40).saturate(50).color,
          ]));
      return Positioned.fill(
          child: Container(
              decoration: decoration,
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                CachedNetworkImage(
                  width: 140,
                  imageUrl:
                      "${BungieApiService.baseUrl}${itemDefinition.secondaryIcon}",
                  fit: BoxFit.fitWidth,
                  alignment: AlignmentDirectional.topEnd,
                )
              ])));
    }
    return Container();
  }

  double get iconSize {
    return 80;
  }

  double get padding {
    return 8;
  }

  Color get defaultTextColor {
    return DestinyData.getDamageTypeColor(DamageType.Kinetic);
  }

  double get titleFontSize {
    return 14;
  }
}
