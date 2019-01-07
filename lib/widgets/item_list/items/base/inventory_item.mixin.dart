import 'package:bungie_api/enums/damage_type_enum.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie-api/bungie-api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/utils/shimmer-helper.dart';

mixin InventoryItemMixin implements StatelessWidget {
  final DestinyItemComponent item = null;
  final ProfileService profile = new ProfileService();
  final ManifestService manifest = new ManifestService();
  final DestinyInventoryItemDefinition definition = null;
  final DestinyItemInstanceComponent instanceInfo = null;

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
        child: borderedIcon(context));
  }

  Widget borderedIcon(BuildContext context) {
    return Container(
        decoration: iconBoxDecoration(), child: itemIconImage(context));
  }

  BoxDecoration iconBoxDecoration() {
    return BoxDecoration(
        border:
            Border.all(color: Colors.grey.shade300, width: iconBorderWidth));
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
    return Container();
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
          decoration: nameBarBoxDecoration(),
          child: nameBarTextField(context),
        ));
  }

  BoxDecoration nameBarBoxDecoration(){
    return BoxDecoration(color: DestinyData.getTierColor(definition.inventory.tierType));
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
      onTap: () {
        profile.fetchBasicProfile();
      },
    );
  }

  double get iconSize {
    return 80;
  }

  double get iconBorderWidth {
    return 2;
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
