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

  BaseItemStatWidget(this.statHash, this.modValues, {this.scaled});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Container(
          padding: EdgeInsets.symmetric(vertical: 1),
          child: Row(children: [
            Expanded(child:ManifestText<DestinyStatDefinition>(
                  statHash,
                  key: Key("item_stat_$statHash"),
                  uppercase: true,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold, fontSize: 12),
                  overflow: TextOverflow.fade,
                )),
            Expanded(child: Text("$precalculated"),),
            Expanded(child: Text("$currentValue"),),
            Expanded(child: Text("$masterwork"),)
          ]));
    });
  }

  int get maxBarSize {
    if (DestinyData.armorStats.contains(statHash)) {
      return max(3, baseBarSize + modBarSize);
    }
    return max(100, baseBarSize + modBarSize);
  }

  int get currentValue {
    var originalValue =  selected + masterwork;
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

  Color get modColor {
    if (selected > equipped) {
      return DestinyData.positiveFeedback;
    }
    if (equipped > selected) {
      return DestinyData.negativeFeedback;
    }
    if (masterwork > 0) {
      return Colors.amberAccent.shade400;
    }
    return color;
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

  Color get color {
    return hiddenStat ? Colors.amber.shade200 : Colors.grey.shade300;
  }

  bool get hiddenStat {
    return DestinyData.hiddenStats.contains(statHash);
  }

  bool get noBar {
    return scaled?.displayAsNumeric ?? false;
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
  StatValues({this.equipped = 0, this.selected=0, this.masterwork=0, this.precalculated=0});
}