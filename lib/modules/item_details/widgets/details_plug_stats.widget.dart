import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/utils/helpers/stat_helpers.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:tinycolor2/tinycolor2.dart';

class DetailsPlugStatsWidget extends StatelessWidget {
  final List<StatComparison> stats;
  final int? selectedPlugHash;
  final int? equippedPlugHash;

  const DetailsPlugStatsWidget(
    this.stats, {
    int? this.selectedPlugHash,
    int? this.equippedPlugHash,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: context.theme.surfaceLayers.layer0,
          borderRadius: BorderRadius.circular(4),
        ),
        margin: EdgeInsets.only(top: 4),
        padding: EdgeInsets.all(4),
        child: buildTable(context));
  }

  Widget buildTable(BuildContext context) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: {
        0: IntrinsicColumnWidth(flex: 2),
        1: FlexColumnWidth(isSamePlug ? 2 : 1),
      },
      children: [
        buildHeaderRow(context),
        ...stats.map((stat) => buildStatRow(context, stat)).toList(),
      ],
    );
  }

  bool get isSamePlug => selectedPlugHash == equippedPlugHash;

  TableRow buildHeaderRow(BuildContext context) {
    return TableRow(
      children: [
        Container(),
        Container(
            alignment: Alignment.center,
            child: Container(
              width: 24,
              height: 24,
              child: ManifestImageWidget<DestinyInventoryItemDefinition>(selectedPlugHash),
            )),
        if (!isSamePlug)
          Container(
              alignment: Alignment.center,
              child: Container(
                width: 24,
                height: 24,
                child: ManifestImageWidget<DestinyInventoryItemDefinition>(equippedPlugHash),
              )),
        if (!isSamePlug) Icon(FontAwesomeIcons.plusMinus, size: 16),
      ],
    );
  }

  TableRow buildStatRow(BuildContext context, StatComparison stat) {
    return TableRow(children: [
      ManifestText<DestinyStatDefinition>(
        stat.statHash,
        textAlign: TextAlign.end,
        softWrap: false,
      ),
      buildStatValue(context, stat.selected, stat.selectedDiffType),
      if (!isSamePlug) buildStatValue(context, stat.equipped, stat.equippedDiffType),
      if (!isSamePlug) buildStatValue(context, stat.diff, stat.diffType),
    ]);
  }

  Widget buildStatValue(BuildContext context, int value, StatDifferenceType diffType) {
    final color = diffType == StatDifferenceType.Neutral
        ? context.theme.onSurfaceLayers.layer0
        : diffType == StatDifferenceType.Positive
            ? context.theme.successLayers.layer3
            : context.theme.errorLayers.layer3;
    final text = value > 0 ? "+$value" : "$value";
    return Text(
      text,
      textAlign: TextAlign.center,
      softWrap: false,
      style: context.textTheme.highlight.copyWith(
        color: color.mix(context.theme.onSurfaceLayers.layer0, 10),
      ),
    );
  }
}
