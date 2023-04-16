import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/helpers/stat_helpers.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:tinycolor2/tinycolor2.dart';

class DetailsPlugResourceCostWidget extends StatelessWidget {
  final int plugHash;

  const DetailsPlugResourceCostWidget(
    this.plugHash,
  );

  @override
  Widget build(BuildContext context) {
    final itemDef = context.definition<DestinyInventoryItemDefinition>(plugHash);
    final materialRequirementDef =
        context.definition<DestinyMaterialRequirementSetDefinition>(itemDef?.plug?.insertionMaterialRequirementHash);
    final materials = materialRequirementDef?.materials;
    if (materials == null || materials.isEmpty) return Container();
    return Container(
        decoration: BoxDecoration(
          color: context.theme.surfaceLayers.layer0,
          borderRadius: BorderRadius.circular(4),
        ),
        margin: EdgeInsets.only(top: 4),
        padding: EdgeInsets.all(4),
        child: buildTable(context, materials));
  }

  Widget buildTable(BuildContext context, List<DestinyMaterialRequirement> materials) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: {0: FixedColumnWidth(24), 2: IntrinsicColumnWidth()},
      children: materials
          .where((requirement) => (requirement.count ?? 0) > 0)
          .map((requirement) => buildStatRow(context, requirement))
          .toList(),
    );
  }

  TableRow buildStatRow(BuildContext context, DestinyMaterialRequirement requirement) {
    return TableRow(children: [
      Container(
          width: 16,
          height: 16,
          child: ManifestImageWidget<DestinyInventoryItemDefinition>(
            requirement.itemHash,
          )),
      ManifestText<DestinyInventoryItemDefinition>(
        requirement.itemHash,
        softWrap: false,
        style: context.textTheme.caption,
      ),
      Text("${requirement.count}"),
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
