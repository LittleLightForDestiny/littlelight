import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:little_light/shared/widgets/stats/small_armor_stats.widget.dart';

class InventoryItemStats extends StatelessWidget with WishlistsConsumer {
  final DestinyItemInfo itemInfo;
  final double iconSize;
  final double textWidth;
  final EdgeInsets iconMargin;
  InventoryItemStats(
    this.itemInfo, {
    this.iconSize = 16,
    this.textWidth = 18,
    this.iconMargin = const EdgeInsets.only(right: 1),
  });
  @override
  Widget build(BuildContext context) {
    final stats = itemInfo.stats;
    return SmallArmorStatsWidget(
      stats,
      iconSize: this.iconSize,
      iconMargin: this.iconMargin,
      textWidth: textWidth,
    );
  }
}
