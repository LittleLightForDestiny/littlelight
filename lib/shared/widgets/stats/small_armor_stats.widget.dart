import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

class SmallArmorStatsWidget extends StatelessWidget with WishlistsConsumer {
  final Map<String, DestinyStat>? stats;
  final double iconSize;
  final double iconLeftMargin;
  final double iconRightMargin;
  SmallArmorStatsWidget(
    this.stats, {
    this.iconSize = 16,
    this.iconLeftMargin = 4,
    this.iconRightMargin = 1,
  });
  @override
  Widget build(BuildContext context) {
    final stats = this.stats;
    if (stats == null) return Container();
    final firstRow = stats.values.take(3);
    final secondRow = stats.values.skip(3).take(3);
    return Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        defaultColumnWidth: IntrinsicColumnWidth(),
        columnWidths: {
          0: FixedColumnWidth(iconSize + iconRightMargin),
          2: FixedColumnWidth(iconSize + iconLeftMargin + iconRightMargin),
          4: FixedColumnWidth(iconSize + iconLeftMargin + iconRightMargin),
        },
        children: [
          TableRow(
              children: firstRow //
                  .expand((stat) => buildStat(context, stat))
                  .whereType<Widget>()
                  .toList()),
          TableRow(
              children: secondRow //
                  .expand((stat) => buildStat(context, stat))
                  .whereType<Widget>()
                  .toList())
        ]);
  }

  List<Widget> buildStat(BuildContext context, DestinyStat stat) {
    final statHash = stat.statHash;
    if (statHash == null) return [];
    return [
      Container(
        margin: EdgeInsets.only(right: iconRightMargin),
        width: iconSize,
        height: iconSize,
        alignment: Alignment.centerRight,
        child: ManifestImageWidget<DestinyStatDefinition>(statHash),
      ),
      Container(
        child: Text(
          statValue(stat),
          style: context.textTheme.subtitle.copyWith(fontSize: 12),
          textAlign: TextAlign.end,
        ),
      ),
    ];
  }

  String statValue(DestinyStat stat) {
    final value = stat.value?.clamp(0, 999) ?? 0;
    return "$value".padLeft(2, "0");
  }
}
