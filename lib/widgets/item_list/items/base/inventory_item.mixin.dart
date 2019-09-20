import 'package:bungie_api/enums/damage_type_enum.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateless_item.widget.dart';
import 'package:little_light/widgets/common/item_icon/item_icon.widget.dart';
import 'package:little_light/widgets/common/item_name_bar/item_name_bar.widget.dart';

mixin InventoryItemMixin implements DestinyItemWidget {
  final String uniqueId = "";
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        background(context),
        positionedNameBar(context),
        categoryName(context),
        primaryStatWidget(context),
        positionedIcon(context),
        perksWidget(context),
        modsWidget(context),
      ].where((w) => w != null).toList(),
    );
  }

  Widget positionedIcon(BuildContext context) {
    return Positioned(
        top: padding,
        left: padding,
        width: iconSize,
        height: iconSize,
        child: itemIconHero(context));
  }

  Widget itemIconHero(BuildContext context) {
    return Hero(
      tag: "item_icon_${tag}_$uniqueId",
      child: itemIcon(context),
    );
  }

  itemIcon(BuildContext context) {
    return ItemIconWidget(
      item,
      definition,
      instanceInfo,
      iconBorderWidth: iconBorderWidth,
    );
  }

  Widget primaryStatWidget(BuildContext context) {
    return Container();
  }

  Widget perksWidget(BuildContext context){
    return Container();
  }

  Widget modsWidget(BuildContext context){
    return Container();
  }

  Widget categoryName(BuildContext context) {
    return Positioned(
        left: padding * 2 + iconSize,
        top: padding * 2.5 + titleFontSize,
        child: Text(
          definition?.itemTypeDisplayName ?? "",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
        ));
  }

  Widget positionedNameBar(BuildContext context) {
    return Positioned(
        left: 0,
        right: 0,
        child: itemHeroNamebar(context));
  }

  Widget itemHeroNamebar(BuildContext context){
    return Hero(
      tag: "item_namebar_${tag}_$uniqueId",
      child: nameBar(context));
  }

  Widget nameBar(BuildContext context){
    return ItemNameBarWidget(item, definition, instanceInfo,
            padding: EdgeInsets.only(
                left: iconSize + padding * 2,
                top: padding,
                bottom: padding,
                right: padding));
  }

  background(BuildContext context) {
    return Positioned(
        top: 0,
        left: 0,
        bottom: 0,
        right: 0,
        child: Container(color: Colors.blueGrey.shade900));
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
