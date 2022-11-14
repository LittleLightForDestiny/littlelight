import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/models/parsed_wishlist.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:little_light/shared/utils/extensions/wishlist_tag_data.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

class InventoryItemPerks extends StatelessWidget with WishlistsConsumer {
  final DestinyInventoryItemDefinition definition;
  final DestinyItemInfo itemInfo;
  final int categoryHash;
  final double plugSize;
  InventoryItemPerks(
    this.itemInfo, {
    required this.definition,
    required this.categoryHash,
    this.plugSize = 20,
  });
  @override
  Widget build(BuildContext context) {
    final sockets = itemInfo.sockets;
    final socketCategory = definition.sockets?.socketCategories //
        ?.firstWhereOrNull((c) => c.socketCategoryHash == categoryHash);
    final plugs = socketCategory?.socketIndexes?.map((e) => sockets?[e]).whereType<DestinyItemSocketState>();
    if (plugs == null || plugs.isEmpty) return Container();
    return Row(
      children: plugs //
          .where((p) => (p.isVisible ?? false) && (p.isEnabled ?? false))
          .map((p) => buildPlug(context, p.plugHash))
          .whereType<Widget>()
          .toList(),
    );
  }

  Widget? buildPlug(BuildContext context, int? plugHash) {
    if (plugHash == null) return null;
    return Stack(
        fit: StackFit.loose,
        children: [
          Positioned.fill(child: buildWishlistBackground(context, plugHash) ?? Container()),
          Container(
            width: plugSize,
            height: plugSize,
            child: ManifestImageWidget<DestinyInventoryItemDefinition>(plugHash),
          ),
        ].whereType<Widget>().toList());
  }

  Widget? buildWishlistBackground(BuildContext context, int plugHash) {
    final itemHash = itemInfo.item.itemHash;
    if (itemHash == null) return null;
    final tags = wishlistsService.getPlugTags(itemHash, plugHash);
    if (tags.isEmpty) return null;
    final borderRadius = BorderRadius.circular(4);
    final borderWidth = 1.0;
    if (tags.isAllAround) {
      final isGodPvE = tags.contains(WishlistTag.GodPVE);
      final isGodPvP = tags.contains(WishlistTag.GodPVP);
      final pveBorderColor = (isGodPvE ? WishlistTag.GodPVE : WishlistTag.PVE).getBorderColor(context);
      final pvpBorderColor = (isGodPvP ? WishlistTag.GodPVP : WishlistTag.PVP).getBorderColor(context);

      return Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                colors: [pveBorderColor, pvpBorderColor],
                stops: [.49, .51],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(borderWidth),
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                colors: [WishlistTag.PVE.getBorderColor(context), WishlistTag.PVP.getBorderColor(context)],
                stops: [.49, .51],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ],
      );
    }
    if (tags.isPvE) {
      final isGodPvE = tags.contains(WishlistTag.GodPVE);
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: WishlistTag.PVE.getColor(context),
          border: isGodPvE ? Border.all(width: borderWidth, color: WishlistTag.GodPVE.getBorderColor(context)) : null,
        ),
      );
    }
    if (tags.isPvP) {
      final isGodPvE = tags.contains(WishlistTag.GodPVP);
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: WishlistTag.PVP.getColor(context),
          border: isGodPvE ? Border.all(width: borderWidth, color: WishlistTag.GodPVP.getBorderColor(context)) : null,
        ),
      );
    }
    return null;
  }
}
