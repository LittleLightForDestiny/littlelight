import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/wish_list.dart';
import 'package:little_light/services/littlelight/wishlists.service.dart';

import 'package:little_light/widgets/common/base/base_destiny_stateless_item.widget.dart';
import 'package:little_light/widgets/common/primary_stat.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/icon_fonts/destiny_icons_icons.dart';

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
            Container(
              decoration: BoxDecoration(
                  color: Colors.blue.shade800,
                  borderRadius: BorderRadius.circular(4)),
              padding: EdgeInsets.all(2),
              child: Icon(DestinyIcons.vanguard, size: 14),
            ),
            Container(
              width: 4,
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.red.shade800,
                  borderRadius: BorderRadius.circular(4)),
              padding: EdgeInsets.all(2),
              child: Icon(DestinyIcons.crucible, size: 14),
            ),
            Container(
              width: 8,
            ),
            TranslatedTextWidget(
                "This item is considered a godroll for both PvE and PvP.")
          ]));
    }
    if (tags.contains(WishlistTag.PVE)) {
      return Container(
          padding: EdgeInsets.only(bottom: 8, left: 8, right: 8),
          child: Row(children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.blue.shade800,
                  borderRadius: BorderRadius.circular(4)),
              padding: EdgeInsets.all(2),
              child: Icon(DestinyIcons.vanguard, size: 14),
            ),
            Container(
              width: 8,
            ),
            TranslatedTextWidget("This item is considered a PvE godroll.")
          ]));
    }
    if (tags.contains(WishlistTag.PVP)) {
      return Container(
          padding: EdgeInsets.only(bottom: 8, left: 8, right: 8),
          child: Row(children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.red.shade800,
                  borderRadius: BorderRadius.circular(4)),
              padding: EdgeInsets.all(2),
              child: Icon(DestinyIcons.crucible, size: 14),
            ),
            Container(
              width: 8,
            ),
            TranslatedTextWidget("This item is considered a PvP godroll.")
          ]));
    }
    if (tags.contains(WishlistTag.Bungie)) {
      return Container(
          padding: EdgeInsets.only(bottom: 8, left: 8, right: 8),
          child: Row(children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(4)),
              padding: EdgeInsets.all(2),
              child: Icon(DestinyIcons.bungie, size: 14),
            ),
            Container(
              width: 8,
            ),
            TranslatedTextWidget("This item is a Bungie curated roll.")
          ]));
    }
    if (tags.contains(WishlistTag.Trash)) {
      return Container(
          padding: EdgeInsets.only(bottom: 8, left: 8, right: 8),
          child: Row(children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.lightGreen.shade500,
                  borderRadius: BorderRadius.circular(4)),
              padding: EdgeInsets.all(2),
              child: Text(
                "🤢",
                style: TextStyle(fontSize: 14, height: 1.3),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              width: 8,
            ),
            TranslatedTextWidget("This item is considered a trash roll.")
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
