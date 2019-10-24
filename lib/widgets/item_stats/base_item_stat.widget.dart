import 'dart:math';
import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:bungie_api/models/destiny_stat_display_definition.dart';
import 'package:bungie_api/models/interpolation_point.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

class BaseItemStatWidget extends StatelessWidget {
  final int statHash;
  final StatValues modValues;
  final DestinyStatDisplayDefinition scaled;

  BaseItemStatWidget({this.statHash, this.modValues, this.scaled, Key key}):super(key:key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 400,
        padding: EdgeInsets.symmetric(vertical: 1),
        child: Row(children: [
          Expanded(
              child: ManifestText<DestinyStatDefinition>(
            statHash,
            key: Key("item_stat_$statHash"),
            uppercase: true,
            maxLines: 1,
            softWrap: false,
            style: TextStyle(
                color: nameColor, fontWeight: FontWeight.bold, fontSize: 12),
            overflow: TextOverflow.fade,
          )),
          Expanded(
            child: Text("$precalculated"),
          ),
          Expanded(
            child: Text("$currentValue"),
          ),
          Expanded(
            child: Text("$masterwork"),
          )
        ]));
  }

  Color get positiveColor => DestinyData.positiveFeedback;
  Color get negativeColor => DestinyData.negativeFeedback;
  Color get masterworkColor => DestinyData.masterworkColor;
  Color get hiddenStatColor => Colors.cyan.shade100;
  Color get neutralColor => Colors.grey.shade300;

  int get maxBarSize {
    if(scaled?.maximumValue != null){
      return max(scaled?.maximumValue, baseBarSize + modBarSize + masterworkBarSize);
    }
    return max(100, baseBarSize + modBarSize + masterworkBarSize);
  }

  int get currentValue {
    var originalValue = selected + masterwork;
    if (scaled != null) {
      return interpolate(originalValue, scaled.displayInterpolation);
    }
    return originalValue;
  }

  int get selected => modValues?.selected ?? 0;
  int get equipped => modValues?.equipped ?? 0;
  int get masterwork => modValues?.masterwork ?? 0;
  int get precalculated => modValues?.precalculated ?? 0;

  int get baseBarSize {
    var value = min(equipped, selected);
    if (scaled != null) {
      return interpolate(value, scaled.displayInterpolation);
    }
    return value;
  }

  int get modBarSize {
    if (scaled != null) {
      return (InventoryUtils.interpolateStat(
                  selected, scaled.displayInterpolation) -
              InventoryUtils.interpolateStat(
                  equipped, scaled.displayInterpolation))
          .abs();
    }
    return (selected - equipped).abs();
  }

  int get masterworkBarSize {
    if (scaled != null) {
      return (InventoryUtils.interpolateStat(
                  selected + masterwork, scaled.displayInterpolation) -
              InventoryUtils.interpolateStat(
                  selected, scaled.displayInterpolation))
          .abs();
    }
    return (masterwork).abs();
  }

  Color get nameColor{
    if(isHiddenStat){
      return hiddenStatColor;
    }
    return neutralColor;
  }

  Color get valueColor{
    if(masterwork > 0){
      return masterworkColor;
    }
    if (selected > equipped) {
      return positiveColor;
    }
    if (equipped > selected) {
      return negativeColor;
    }
    if(isHiddenStat){
      return hiddenStatColor;
    }
    return neutralColor;
  }

  Color get modBarColor {
    if (selected > equipped) {
      return positiveColor;
    }
    if (equipped > selected) {
      return negativeColor;
    }
    return neutralColor;
  }


  bool get isHiddenStat {
    return DestinyData.hiddenStats.contains(statHash);
  }

  bool get noBar {
    return scaled?.displayAsNumeric ?? false;
  }

  bool get isDirection{
    return statHash == 2715839340;
  }

  interpolate(int i, List<InterpolationPoint> displayInterpolation) {
    return InventoryUtils.interpolateStat(i, displayInterpolation);
  }
}

class StatValues {
  int precalculated;
  int equipped;
  int selected;
  int masterwork;
  StatValues(
      {this.equipped = 0,
      this.selected = 0,
      this.masterwork = 0,
      this.precalculated = 0});
}
