import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

class SmallArmorStatsWidget extends StatelessWidget with WishlistsConsumer {
  final Map<String, DestinyStat>? stats;
  final double iconSize;
  final EdgeInsets iconMargin;
  final double textWidth;
  SmallArmorStatsWidget(
    this.stats, {
    this.iconSize = 16,
    this.textWidth = 18,
    this.iconMargin = const EdgeInsets.only(right: 1),
  });
  @override
  Widget build(BuildContext context) {
    final stats = this.stats;
    if (stats == null) return Container();
    final firstRow = stats.values.take(3);
    final secondRow = stats.values.skip(3).take(3);
    return Column(children: [
      Row(
          children: firstRow //
              .map((stat) => buildStat(context, stat))
              .whereType<Widget>()
              .toList()),
      Row(
          children: secondRow //
              .map((stat) => buildStat(context, stat))
              .whereType<Widget>()
              .toList())
    ]);
  }

  Widget? buildStat(BuildContext context, DestinyStat stat) {
    final statHash = stat.statHash;
    if (statHash == null) return null;
    return Container(
      child: Row(
        children: [
          Container(
            margin: iconMargin,
            width: iconSize,
            height: iconSize,
            child: ManifestImageWidget<DestinyStatDefinition>(statHash),
          ),
          SizedBox(
            width: textWidth,
            child: Text(
              statValue(stat),
              style: context.textTheme.subtitle.copyWith(fontSize: 12),
              textAlign: TextAlign.end,
            ),
          ),
          Container(width: 4),
        ],
      ),
    );
  }

  String statValue(DestinyStat stat) {
    final value = stat.value?.clamp(0, 100) ?? 0;
    return "$value".padLeft(2, "0");
  }
}
