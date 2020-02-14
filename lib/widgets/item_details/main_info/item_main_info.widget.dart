import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/wish_list.dart';
import 'package:little_light/services/littlelight/wishlists.service.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateless_item.widget.dart';
import 'package:little_light/widgets/common/primary_stat.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/common/wishlist_badge.widget.dart';

class ItemMainInfoWidget extends BaseDestinyStatelessItemWidget {
  ItemMainInfoWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key,
      String characterId})
      : super(
            item: item,
            definition: definition,
            instanceInfo: instanceInfo,
            key: key,
            characterId: characterId);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(definition?.itemTypeDisplayName ?? ""),
              Padding(
                  padding: EdgeInsets.only(top: 8), child: primaryStat(context))
            ],
          ),
          Container(
            height: 1,
            color: Colors.grey.shade300,
            margin: EdgeInsets.symmetric(vertical: 8),
          ),
          Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                definition.displayProperties.description,
              )),
          buildWishListInfo(context)
        ]));
  }

  Widget buildWishListInfo(BuildContext context) {
    var tags = WishlistsService().getWishlistBuildTags(item);
    if (tags == null) return Container();
    if (tags.contains(WishlistTag.PVE) && tags.contains(WishlistTag.PVP)) {
      return Container(
          padding: EdgeInsets.only(bottom: 8, left: 8, right: 8),
          child: Row(children: [
            WishlistBadgeWidget(
                tags: [WishlistTag.PVE, WishlistTag.PVP].toSet()),
            Container(
              width: 8,
            ),
            Expanded(child:TranslatedTextWidget(
                "This item is considered a godroll for both PvE and PvP."))
          ]));
    }
    if (tags.contains(WishlistTag.PVE)) {
      return Container(
          padding: EdgeInsets.only(bottom: 8, left: 8, right: 8),
          child: Row(children: [
            WishlistBadgeWidget(tags: [WishlistTag.PVE].toSet()),
            Container(
              width: 8,
            ),
            Expanded(child:TranslatedTextWidget("This item is considered a PvE godroll."))
          ]));
    }
    if (tags.contains(WishlistTag.PVP)) {
      return Container(
          padding: EdgeInsets.only(bottom: 8, left: 8, right: 8),
          child: Row(children: [
            WishlistBadgeWidget(tags: [WishlistTag.PVP].toSet()),
            Container(
              width: 8,
            ),
            Expanded(child:TranslatedTextWidget("This item is considered a PvP godroll."))
          ]));
    }
    if (tags.contains(WishlistTag.Bungie)) {
      return Container(
          padding: EdgeInsets.only(bottom: 8, left: 8, right: 8),
          child: Row(children: [
            WishlistBadgeWidget(tags: [WishlistTag.Bungie].toSet()),
            Container(
              width: 8,
            ),
            Expanded(child:TranslatedTextWidget("This item is a Bungie curated roll."))
          ]));
    }
    if (tags.contains(WishlistTag.Trash)) {
      return Container(
          padding: EdgeInsets.only(bottom: 8, left: 8, right: 8),
          child: Row(children: [
            WishlistBadgeWidget(tags: [WishlistTag.Trash].toSet()),
            Container(
              width: 8,
            ),
            Expanded(
                child: TranslatedTextWidget(
                    "This item is considered a trash roll."))
          ]));
    }
    if(tags.length == 0){
      return Container(
          padding: EdgeInsets.only(bottom: 8, left: 8, right: 8),
          child: Row(children: [
            WishlistBadgeWidget(tags: Set()),
            Container(
              width: 8,
            ),
            Expanded(
                child: TranslatedTextWidget(
                    "This item is considered an uncategorized godroll."))
          ]));
    }
    return Container();
  }

  Widget primaryStat(context) {
    return PrimaryStatWidget(
      definition: definition,
      instanceInfo: instanceInfo,
      suppressLabel: true,
      fontSize: 36,
    );
  }
}
