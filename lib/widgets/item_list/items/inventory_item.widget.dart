import 'package:bungie_api/enums/damage_type_enum.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_stat.dart';
import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie-api/bungie-api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/utils/shimmer-helper.dart';

class InventoryItemWidget extends StatefulWidget {
  final DestinyItemComponent item;
  final ProfileService profile = new ProfileService();
  final ManifestService manifest = new ManifestService();
  final DestinyInventoryItemDefinition definition;
  final DestinyItemInstanceComponent instanceInfo;

  InventoryItemWidget(this.item, this.definition, this.instanceInfo);

  @override
  State<StatefulWidget> createState() {
    return InventoryItemWidgetState();
  }
}

class InventoryItemWidgetState extends State<InventoryItemWidget> {
  DestinyStat primaryStat;
  DestinyStatDefinition statDefinition;
  @override
  void initState() {
    primaryStat = instanceInfo.primaryStat;
    super.initState();
    loadDefinitions();
  }

  loadDefinitions() async {
    if (primaryStat != null) {
      statDefinition =
          await widget.manifest.getStatDefinition(primaryStat.statHash);
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        background(context),
        nameBar(context),
        categoryName(context),
        primaryStatWidget(context),
        itemIcon(context),
        Positioned.fill(
          child: Material(color: Colors.transparent, child: inkWell(context)),
        )
      ].where((w) => w != null).toList(),
    );
  }

  Widget itemIcon(BuildContext context) {
    return Positioned(
        top: padding,
        left: padding,
        width: iconSize,
        height: iconSize,
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 2)),
            child: itemIconImage(context)));
  }

  Widget itemIconImage(BuildContext context) {
    return CachedNetworkImage(
      imageUrl:
          "${BungieApiService.baseUrl}${definition.displayProperties.icon}",
      fit: BoxFit.fill,
      placeholder: itemIconPlaceholder(context),
    );
  }

  Widget itemIconPlaceholder(BuildContext context) {
    return ShimmerHelper.getDefaultShimmer(context);
  }

  Widget primaryStatWidget(BuildContext context) {
    if (primaryStat == null) return null;
    Color damageTypeColor =
        DestinyData.getDamageTypeTextColor(instanceInfo.damageType);
    return Positioned(
        top: titleFontSize + padding,
        right: 0,
        child: Container(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      primaryStatIcon(
                          context,
                          DestinyData.getDamageTypeIcon(
                              definition.defaultDamageType),
                          damageTypeColor,
                          size: 26),
                      primaryStatValueField(context, damageTypeColor),
                      ammoTypeDivider(context),
                      primaryStatIcon(
                          context,
                          DestinyData.getAmmoTypeIcon(
                              definition.equippingBlock.ammoType),
                          DestinyData.getAmmoTypeColor(
                              definition.equippingBlock.ammoType),
                          size: 34),
                    ].where((w) => w != null).toList()),
                primaryStatNameField(context, statDefinition, damageTypeColor)
              ],
            )));
  }

  Widget primaryStatValueField(BuildContext context, Color color) {
    return Text(
      "${primaryStat.value}",
      style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 26),
    );
  }

  Widget primaryStatNameField(
      BuildContext context, DestinyStatDefinition statDef, Color color) {
        if(statDef == null){
          return Container();
        }
    return Text(statDef.displayProperties.name.toUpperCase(),
        style:
            TextStyle(color: color, fontWeight: FontWeight.w300, fontSize: 16));
  }

  Widget primaryStatIcon(BuildContext context, IconData icon, Color color,
      {double size = 22}) {
    return Icon(
      icon,
      color: color,
      size: size,
    );
  }

  Widget ammoTypeDivider(BuildContext context, [double height = 26]) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: padding / 2),
        color: Colors.white,
        width: 1,
        height: height);
  }

  Widget categoryName(BuildContext context) {
    return Positioned(
        left: padding * 2 + iconSize,
        top: padding * 2.5 + titleFontSize,
        child: Text(
          definition.itemTypeDisplayName,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
        ));
  }

  Widget nameBar(BuildContext context) {
    return Positioned(
        left: 0,
        right: 0,
        child: Container(
          padding: EdgeInsets.only(left: iconSize + padding * 2),
          height: titleFontSize + padding * 2,
          alignment: Alignment.centerLeft,
          color: DestinyData.getTierColor(definition.inventory.tierType),
          child: nameBarTextField(context),
        ));
  }

  nameBarTextField(BuildContext context) {
    return Text(definition.displayProperties.name.toUpperCase(),
        overflow: TextOverflow.fade,
        maxLines: 1,
        softWrap: false,
        style: TextStyle(
          fontSize: titleFontSize,
          color: DestinyData.getTierTextColor(definition.inventory.tierType),
          fontWeight: FontWeight.bold,
        ));
  }

  background(BuildContext context) {
    return Positioned(
        top: 0,
        left: 0,
        bottom: 0,
        right: 0,
        child: Container(color: Colors.blueGrey.shade900));
  }

  Widget inkWell(BuildContext context) {
    return InkWell(
      onTap: () {},
    );
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

  DestinyInventoryItemDefinition get definition {
    return widget.definition;
  }

  DestinyItemInstanceComponent get instanceInfo {
    return widget.instanceInfo;
  }
}
