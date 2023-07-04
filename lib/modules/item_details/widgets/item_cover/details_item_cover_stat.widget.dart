import 'dart:math';

import 'package:bungie_api/models/destiny_stat_definition.dart';

import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/utils/helpers/stat_helpers.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/modules/item_details/widgets/direction_stat_bar.widget.dart';
import 'package:tinycolor2/tinycolor2.dart';

const _barAnimationDuration = Duration(milliseconds: 300);

class DetailsItemCoverStatWidget extends StatelessWidget {
  final StatValues modValues;
  final double pixelSize;

  const DetailsItemCoverStatWidget({
    Key? key,
    required StatValues this.modValues,
    this.pixelSize = 1,
  }) : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30 * pixelSize,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: buildParts(context),
      ),
    );
  }

  List<Widget> buildParts(BuildContext context) {
    if (modValues.type == StatType.NoBar) {
      return [
        buildLabel(context),
        buildValue(context),
        Container(width: 212 * pixelSize),
      ];
    }
    if (modValues.type == StatType.Direction) {
      return [
        buildLabel(context),
        buildValue(context),
        buildDirectionBar(context),
      ];
    }
    return [
      buildLabel(context),
      buildBar(context),
      buildValue(context),
    ];
  }

  Widget buildLabel(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(right: 12 * pixelSize),
      child: ManifestText<DestinyStatDefinition>(
        modValues.statHash,
        style: context.textTheme.body.copyWith(color: getBaseColor(context), fontSize: 20 * pixelSize),
        textAlign: TextAlign.end,
        softWrap: false,
      ),
    );
  }

  Widget buildValue(BuildContext context) {
    final currentValue = modValues.selected + modValues.selectedMasterwork;
    return SizedBox(
      width: 42 * pixelSize,
      child: Text(
        "$currentValue",
        style: context.textTheme.highlight.copyWith(color: getValueColor(context), fontSize: 20 * pixelSize),
        textAlign: TextAlign.end,
      ),
    );
  }

  int get maxValue => modValues.maximumValue;

  Widget buildBar(BuildContext context) {
    final width = 212 * pixelSize;
    final baseBarSize = min(modValues.equipped, modValues.selected);
    final diffBarSize = (modValues.selected - modValues.equipped);
    final masterWorkBarSize = max(modValues.selectedMasterwork, modValues.equippedMasterwork);
    final maxBarSize = maxValue;

    final total = baseBarSize + diffBarSize + masterWorkBarSize;
    final isNegative = total < 0;

    return Container(
      width: width,
      height: 18 * pixelSize,
      color: Colors.grey.shade700.withOpacity(.7),
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Container(
          constraints: BoxConstraints(minWidth: width),
          child: Row(
            mainAxisAlignment: isNegative ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: <Widget>[
              AnimatedContainer(
                duration: _barAnimationDuration,
                width: isNegative ? 0 : (baseBarSize / maxBarSize) * (width),
                color: getBaseColor(context),
              ),
              AnimatedContainer(
                duration: _barAnimationDuration,
                width: isNegative ? 0 : (diffBarSize.clamp(0, maxBarSize) / maxBarSize) * (width),
                color: getDiffColor(context, StatDifferenceType.Positive),
              ),
              AnimatedContainer(
                duration: _barAnimationDuration,
                width: isNegative ? 0 : (masterWorkBarSize.clamp(0, maxBarSize) / maxBarSize) * (width),
                color: getMasterworkColor(context),
              ),
              AnimatedContainer(
                duration: _barAnimationDuration,
                width: isNegative ? 0 : (-diffBarSize.clamp(-maxBarSize, 0) / maxBarSize) * (width),
                color: getDiffColor(context, StatDifferenceType.Negative),
              ),
              AnimatedContainer(
                duration: _barAnimationDuration,
                width: isNegative ? (total / maxBarSize).abs() * (width) : 0,
                color: getDiffColor(context, StatDifferenceType.Negative),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDirectionBar(BuildContext context) {
    final current = modValues.selected + modValues.selectedMasterwork;
    return Container(
        width: 212 * pixelSize,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 16 * pixelSize, bottom: 8 * pixelSize),
        child: SizedBox(
            width: 36 * pixelSize,
            height: 18 * pixelSize,
            child: DirectionStatBarWidget(
                currentValue: modValues.selected.toInt(),
                equippedValue: current.round(),
                currentColor: getBaseColor(context),
                equippedColor: getDiffColor(context, modValues.diffType),
                backgroundColor: context.theme.surfaceLayers.layer3)));
  }

  Color getValueColor(BuildContext context) {
    if (modValues.equipped == modValues.selected) return getBaseColor(context);
    return getDiffColor(context, modValues.diffType);
  }

  Color getBaseColor(BuildContext context) => context.theme.onSurfaceLayers.layer2;

  Color getDiffColor(BuildContext context, StatDifferenceType diffType) {
    return (diffType == StatDifferenceType.Positive
            ? context.theme.successLayers.layer3
            : context.theme.errorLayers.layer3)
        .mix(context.theme.onSurfaceLayers.layer1, 20);
  }

  Color getMasterworkColor(BuildContext context) => context.theme.achievementLayers.layer0;
}

class DetailsCoverTotalItemStatWidget extends DetailsItemCoverStatWidget {
  DetailsCoverTotalItemStatWidget({required StatValues modValues, double pixelSize = 1})
      : super(modValues: modValues, pixelSize: pixelSize);

  @override
  int get maxValue => 100;

  Widget buildLabel(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(right: 12 * pixelSize),
      child: Text(
        "Total".translate(context),
        style: context.textTheme.body.copyWith(color: getBaseColor(context), fontSize: 20 * pixelSize),
        textAlign: TextAlign.end,
        softWrap: false,
      ),
    );
  }
}
