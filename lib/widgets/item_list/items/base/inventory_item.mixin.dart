import 'package:bungie_api/enums/damage_type.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/models/wish_list.dart';
import 'package:little_light/services/littlelight/wishlists.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateless_item.widget.dart';
import 'package:little_light/widgets/common/item_icon/item_icon.widget.dart';
import 'package:little_light/widgets/common/item_name_bar/item_name_bar.widget.dart';
import 'package:little_light/widgets/common/primary_stat.widget.dart';
import 'package:little_light/widgets/icon_fonts/destiny_icons_icons.dart';

mixin InventoryItemMixin implements BaseDestinyStatelessItemWidget {
  final String uniqueId = "";
  final Widget trailing = null;
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
    return Positioned(
        top: titleFontSize + padding * 2 + 4,
        right: 4,
        child: Container(
          child: PrimaryStatWidget(
              definition: definition, instanceInfo: instanceInfo),
        ));
  }

  Widget perksWidget(BuildContext context) {
    return Container();
  }

  Widget modsWidget(BuildContext context) {
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
    return Positioned(left: 0, right: 0, child: itemHeroNamebar(context));
  }

  Widget buildStatTotal(BuildContext context) {
    var stats = profile.getPrecalculatedStats(item?.itemInstanceId);
    if (stats == null) {
      return Container();
    }
    int total = stats.values.fold(0, (t, s) => t + s.value);
    Color textColor = Colors.grey.shade500;
    if (total >= 55) {
      textColor = Colors.grey.shade300;
    }
    if (total >= 60) {
      textColor = Colors.amber.shade100;
    }
    return Positioned(
        right: iconBorderWidth,
        top: iconBorderWidth,
        left: iconBorderWidth,
        child: Container(
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
              gradient:
                  LinearGradient(colors: [Colors.transparent, Colors.black])),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                "T$total",
                style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w500,
                    color: textColor),
              )
            ],
          ),
        ));
  }

  Widget itemHeroNamebar(BuildContext context) {
    return Hero(tag: "item_namebar_${tag}_$uniqueId", child: nameBar(context));
  }

  Widget nameBar(BuildContext context) {
    return ItemNameBarWidget(item, definition, instanceInfo,
        trailing: namebarTrailingWidget(context),
        padding: EdgeInsets.only(
            left: iconSize + padding * 2,
            top: padding,
            bottom: padding,
            right: 2));
  }

  background(BuildContext context) {
    return Positioned(
        top: 0,
        left: 0,
        bottom: 0,
        right: 0,
        child: Container(
            color: Colors.blueGrey.shade900,
            padding: EdgeInsets.only(
              top: titleFontSize + padding * 2 + 4,
            ),
            child: wishlistBackground(context)));
  }

  Widget wishlistBackground(BuildContext context) {
    var wishBuild = WishlistsService().getWishlistBuild(item);
    if (wishBuild == null) return Container();
    if (wishBuild.tags.contains(WishlistTag.PVE) &&
        wishBuild.tags.contains(WishlistTag.PVP)) {
      return Image.asset(
        "assets/imgs/allaround-bg.png",
        fit: BoxFit.fitHeight,
        alignment: Alignment.bottomRight,
      );
    }
    if (wishBuild.tags.contains(WishlistTag.PVE)) {
      return Image.asset(
        "assets/imgs/pve-bg.png",
        fit: BoxFit.fitHeight,
        alignment: Alignment.bottomRight,
      );
    }
    if (wishBuild.tags.contains(WishlistTag.PVP)) {
      return Image.asset(
        "assets/imgs/pvp-bg.png",
        fit: BoxFit.fitHeight,
        alignment: Alignment.topRight,
      );
    }
    return Container();
  }

  List<Widget> trailingWishlistIcons(BuildContext context) {
    var wishBuild = WishlistsService().getWishlistBuild(item);
    if (wishBuild == null) return [];
    List<Widget> items = [];
    if (wishBuild.tags.contains(WishlistTag.PVE)) {
      items.add(buildTagIcon(context, Colors.blue.shade800,
          Icon(DestinyIcons.vanguard, size: tagIconSize)));
    }
    if (wishBuild.tags.contains(WishlistTag.PVP)) {
      items.add(buildTagIcon(context, Colors.red.shade800,
          Icon(DestinyIcons.crucible, size: tagIconSize)));
    }
    if (wishBuild.tags.contains(WishlistTag.Trash)) {
      items.add(buildTagIcon(
          context,
          Colors.lightGreen.shade500,
          Text(
            "🤢",
            style: TextStyle(fontSize: tagIconSize, height: 1.3),
            textAlign: TextAlign.center,
          )));
    }
    if (wishBuild.tags.contains(WishlistTag.Bungie)) {
      items.add(buildTagIcon(
          context,
          Colors.black,
          Icon(DestinyIcons.bungie, size: tagIconSize)));
    }
    if(wishBuild.tags.length == 0){
      items.add(buildTagIcon(
          context,
          Colors.amber,
          Icon(FontAwesomeIcons.star, size: tagIconSize)));
    }
    return items;
  }

  Widget buildTagIcon(BuildContext context, Color bgColor, Widget icon) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 2),
        child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: bgColor, borderRadius: BorderRadius.circular(4)),
              child: icon,
            )));
  }

  Widget namebarTrailingWidget(BuildContext context) {
    List<Widget> items = [];
    items.addAll(trailingWishlistIcons(context));
    if (trailing != null) {
      items.add(trailing);
    }
    if ((items?.length ?? 0) == 0) return Container();
    items = items
        .expand((i) => [
              i,
              Container(
                width: padding / 2,
              )
            ])
        .toList();
    items.removeLast();
    return Row(
      children: items,
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

  double get tagIconSize {
    return 22;
  }
}
