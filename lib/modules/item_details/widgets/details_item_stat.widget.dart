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

class DetailsItemStatWidget extends StatelessWidget {
  final StatValues modValues;

  const DetailsItemStatWidget({
    Key? key,
    required StatValues this.modValues,
  }) : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) => SizedBox(
          height: 18,
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(child: buildLabel(context)),
                buildValue(context),
                buildConstrainedBar(context, constraints)
              ])),
    );
  }

  Widget buildLabel(BuildContext context) {
    return Container(
      child: ManifestText<DestinyStatDefinition>(
        modValues.statHash,
        style: context.textTheme.body.copyWith(color: getBaseColor(context)),
        textAlign: TextAlign.end,
        softWrap: false,
      ),
    );
  }

  Widget buildValue(BuildContext context) {
    final currentValue = modValues.selected + modValues.selectedMasterwork;
    return SizedBox(
      width: 50,
      child: Text(
        "$currentValue",
        style: context.textTheme.highlight.copyWith(color: getValueColor(context)),
        textAlign: TextAlign.center,
      ),
    );
  }

  int get maxValue => modValues.maximumValue;

  Widget buildConstrainedBar(BuildContext context, BoxConstraints constraints) {
    final width = constraints.maxWidth / 2;
    final baseBarSize = min(modValues.equipped, modValues.selected);
    final diffBarSize = (modValues.selected - modValues.equipped);
    final masterWorkBarSize = max(modValues.selectedMasterwork, modValues.equippedMasterwork);
    final maxBarSize = maxValue;
    final current = modValues.selected + modValues.selectedMasterwork;
    final total = baseBarSize + diffBarSize + masterWorkBarSize;
    final isNegative = total < 0;

    if (modValues.type == StatType.Direction) {
      return Container(
          width: width,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: SizedBox(
              width: 40,
              child: DirectionStatBarWidget(
                  currentValue: modValues.selected.toInt(),
                  equippedValue: current.round(),
                  currentColor: getBaseColor(context),
                  equippedColor: getDiffColor(context, modValues.diffType),
                  backgroundColor: context.theme.surfaceLayers.layer3)));
    }

    if (modValues.type == StatType.NoBar) {
      return Container(width: width);
    }

    return Container(
      width: width,
      height: 14,
      color: Colors.grey.shade700.withValues(alpha: .7),
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
                width: isNegative ? 0 : (baseBarSize.clamp(0, maxBarSize) / maxBarSize) * (width),
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

class DetailsTotalItemStatWidget extends DetailsItemStatWidget {
  DetailsTotalItemStatWidget({required StatValues modValues}) : super(modValues: modValues);

  @override
  int get maxValue => 103;

  @override
  Widget buildLabel(BuildContext context) {
    return Container(
      child: Text(
        "Total".translate(context),
        style: context.textTheme.body.copyWith(color: getBaseColor(context)),
        textAlign: TextAlign.end,
        softWrap: false,
      ),
    );
  }
}
