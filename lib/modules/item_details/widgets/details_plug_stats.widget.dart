import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/utils/helpers/stat_helpers.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:tinycolor2/tinycolor2.dart';

const _defaultPlugIconSize = 24.0;
const _defaultComparisonIconSize = 16.0;
const _defaultFontSize = 13.0;

class DetailsPlugStatsWidget extends StatelessWidget {
  final List<StatComparison> stats;
  final int? selectedPlugHash;
  final int? equippedPlugHash;
  final double plugIconSize;
  final double comparisonIconSize;
  final double fontSize;

  const DetailsPlugStatsWidget(
    this.stats, {
    this.selectedPlugHash,
    this.equippedPlugHash,
    this.plugIconSize = _defaultPlugIconSize,
    this.comparisonIconSize = _defaultComparisonIconSize,
    this.fontSize = _defaultFontSize,
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
        1: FlexColumnWidth(omitComparison ? 2 : 1),
      },
      children: [
        buildHeaderRow(context),
        ...stats.map((stat) => buildStatRow(context, stat)).toList(),
      ],
    );
  }

  bool get omitComparison => selectedPlugHash == equippedPlugHash || equippedPlugHash == null;

  TableRow buildHeaderRow(BuildContext context) {
    return TableRow(
      children: [
        Container(),
        Container(
            alignment: Alignment.center,
            child: Container(
              width: plugIconSize,
              height: plugIconSize,
              child: ManifestImageWidget<DestinyInventoryItemDefinition>(selectedPlugHash),
            )),
        if (!omitComparison)
          Container(
              alignment: Alignment.center,
              child: Container(
                width: plugIconSize,
                height: plugIconSize,
                child: ManifestImageWidget<DestinyInventoryItemDefinition>(equippedPlugHash),
              )),
        if (!omitComparison) Icon(FontAwesomeIcons.plusMinus, size: comparisonIconSize),
      ],
    );
  }

  TableRow buildStatRow(BuildContext context, StatComparison stat) {
    return TableRow(children: [
      ManifestText<DestinyStatDefinition>(
        stat.statHash,
        textAlign: TextAlign.end,
        softWrap: false,
        style: context.textTheme.body.copyWith(fontSize: fontSize),
      ),
      buildStatValue(context, stat.selected, stat.selectedDiffType),
      if (!omitComparison) buildStatValue(context, stat.equipped, stat.equippedDiffType),
      if (!omitComparison) buildStatValue(context, stat.diff, stat.diffType),
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
        fontSize: fontSize,
      ),
    );
  }
}
