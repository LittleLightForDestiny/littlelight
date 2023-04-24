import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

class InventoryItemMods extends StatelessWidget with WishlistsConsumer {
  final DestinyItemInfo itemInfo;
  final int categoryHash;
  final double plugSize;
  final EdgeInsets plugMargin;
  InventoryItemMods(
    this.itemInfo, {
    required this.categoryHash,
    this.plugSize = 28,
    this.plugMargin = const EdgeInsets.only(right: 1),
  });
  @override
  Widget build(BuildContext context) {
    final definition = context.definition<DestinyInventoryItemDefinition>(itemInfo.itemHash);
    final sockets = itemInfo.sockets;
    final socketCategory = definition?.sockets?.socketCategories //
        ?.firstWhereOrNull((c) => c.socketCategoryHash == categoryHash);
    final plugs = socketCategory?.socketIndexes?.map((e) => sockets?[e]).whereType<DestinyItemSocketState>();
    if (plugs == null || plugs.isEmpty) return Container();
    return SizedBox(
      height: plugSize,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: plugs //
            .where((p) => (p.isVisible ?? false) && (p.isEnabled ?? false))
            .map((p) => buildPlug(context, p.plugHash))
            .whereType<Widget>()
            .toList(),
      ),
    );
  }

  Widget? buildPlug(BuildContext context, int? plugHash) {
    if (plugHash == null) return null;
    return Container(
      margin: plugMargin,
      decoration: BoxDecoration(
        color: context.theme.surfaceLayers,
        border: Border.all(
          width: .5,
          color: context.theme.onSurfaceLayers.layer0,
        ),
      ),
      width: plugSize,
      height: plugSize,
      child: ManifestImageWidget<DestinyInventoryItemDefinition>(plugHash),
    );
  }
}
