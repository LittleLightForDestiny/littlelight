// @dart=2.9

import 'package:bungie_api/enums/destiny_item_type.dart';
import 'package:bungie_api/enums/item_state.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/widgets/common/wishlist_corner_badge.decoration.dart';
import 'package:little_light/widgets/item_list/items/base/base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/base/minimal_info_label.mixin.dart';
import 'package:little_light/shared/widgets/tags/tag_pill.widget.dart';

class MinimalBaseInventoryItemWidget extends BaseInventoryItemWidget with MinimalInfoLabelMixin, ProfileConsumer {
  MinimalBaseInventoryItemWidget(DestinyItemComponent item, DestinyInventoryItemDefinition itemDefinition,
      DestinyItemInstanceComponent instanceInfo,
      {@required String characterId, Key key, @required String uniqueId})
      : super(item, itemDefinition, instanceInfo, uniqueId: uniqueId, characterId: characterId, key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        positionedIcon(context),
        primaryStatWidget(context),
        buildMiddleInfoRow(context),
        buildTagsBadges(context),
      ].where((w) => w != null).toList(),
    );
  }

  Widget buildTagsBadges(BuildContext context) {
    final reusable = profile.getItemReusablePlugs(item?.itemInstanceId);
    final tags = wishlistsService.getWishlistBuildTags(itemHash: item?.itemHash, reusablePlugs: reusable);
    if (tags == null) return Container();
    return Positioned.fill(
        child: FractionallySizedBox(
            alignment: Alignment.topRight,
            widthFactor: .3,
            child: Container(
                margin: const EdgeInsets.all(2), foregroundDecoration: WishlistCornerBadgeDecoration(tags: tags))));
  }

  @override
  Widget positionedIcon(BuildContext context) {
    return Positioned(top: 0, left: 0, right: 0, bottom: 0, child: itemIcon(context));
  }

  @override
  Widget primaryStatWidget(BuildContext context) {
    if ([DestinyItemType.Subclass, DestinyItemType.Engram].contains(definition?.itemType)) {
      return Container();
    }
    if ((definition?.inventory?.maxStackSize ?? 0) > 1) {
      return infoContainer(
          context,
          Text(
            "x${item.quantity}",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.right,
          ));
    }
    if (instanceInfo?.primaryStat?.value != null) {
      return infoContainer(
          context,
          Text(
            "${instanceInfo?.primaryStat?.value}",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.right,
          ));
    }
    return super.primaryStatWidget(context);
  }

  Widget buildItemTags(BuildContext context) {
    return Container();
  }

  Widget buildMiddleInfoRow(BuildContext context) {
    var locked = item?.state?.contains(ItemState.Locked) ?? false;
    return Positioned(
        right: padding,
        bottom: titleFontSize + padding * 4,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            buildItemTags(context),
            if (locked) Container(child: Icon(FontAwesomeIcons.lock, size: titleFontSize))
          ],
        ));
  }

  @override
  double get iconBorderWidth {
    return 1;
  }

  @override
  double get padding {
    return 4;
  }

  @override
  double get titleFontSize {
    return 12;
  }
}
