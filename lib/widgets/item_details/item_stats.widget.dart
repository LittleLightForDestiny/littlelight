import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_stat_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_item_socket_state.dart';
import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/destiny_item.stateful_widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

const List<int> _noBarStats = [
  4284893193, // Rounds Per Minute
  3871231066, // Magazine
  2961396640, // Charge Time
  1931675084, //Inventory Size

  2996146975, // Mobility
  392767087, // Resilience
  1943323491, //recovery
];

const List<int> _hiddenStats = [
  1345609583, // Aim Assistance
  2715839340, // Recoil Direction
  3555269338, // Zoom
];

class ItemStatsWidget extends DestinyItemStatefulWidget {
  final Map<int, int> selectedPerks;

  ItemStatsWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key,
      this.selectedPerks})
      : super(item, definition, instanceInfo, key: key);

  @override
  DestinyItemState<DestinyItemStatefulWidget> createState() {
    return ItemStatsWidgetState();
  }
}

class ItemStatsWidgetState extends DestinyItemState<ItemStatsWidget> {
  Map<int, int> modStats;
  Map<int, int> selectedModStats;

  @override
  void initState() {
    super.initState();
    if (item != null) {
      loadModStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (definition?.stats == null) {
      return Container();
    }
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          HeaderWidget(
              child: Container(
            alignment: Alignment.centerLeft,
            child: TranslatedTextWidget(
              "Stats",
              uppercase: true,
              textAlign: TextAlign.left,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          )),
          Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Column(children: buildStats(context))),
          RaisedButton(
            onPressed: loadModStats,
          )
        ],
      ),
    );
  }

  buildStats(context) {
    return stats.map((stat) {
      var modValue = modStats != null ? modStats[stat.statHash] : null;
      var selectedModValue =
          selectedModStats != null ? selectedModStats[stat.statHash] : null;
      return ItemStatWidget(stat, modValue, selectedModValue);
    }).toList();
  }

  Iterable<DestinyInventoryItemStatDefinition> get stats {
    List<DestinyInventoryItemStatDefinition> stats = definition
        .stats.stats.values
        .where((stat) => DestinyData.statWhitelist.contains(stat.statHash))
        .toList();

    stats.sort((statA, statB) {
      int valA = _noBarStats.contains(statA.statHash)
          ? 2
          : _hiddenStats.contains(statA.statHash) ? 1 : 0;
      int valB = _noBarStats.contains(statB.statHash)
          ? 2
          : _hiddenStats.contains(statB.statHash) ? 1 : 0;
      return valA - valB;
    });
    return stats;
  }

  loadModStats() async {
    List<int> hashes = socketStates
        .map((state) => state.plugHash)
        .where((i) => i != null)
        .toList();
    List<int> selectedHashes = widget.selectedPerks.values.toList();
    Map<int, int> modStats = Map<int, int>();
    Map<int, int> selectedModStats = Map<int, int>();
    Map<int, DestinyInventoryItemDefinition> defs = await widget.manifest
        .getDefinitions<DestinyInventoryItemDefinition>(
            hashes + selectedHashes);
    hashes.forEach((hash) {
      DestinyInventoryItemDefinition def = defs[hash];
      def.investmentStats.forEach((stat) {
        modStats[stat.statTypeHash] =
            (modStats[stat.statTypeHash] ?? 0) + stat.value;
      });
    });

    selectedHashes.forEach((hash) {
      DestinyInventoryItemDefinition def = defs[hash];
      def.investmentStats.forEach((stat) {
        selectedModStats[stat.statTypeHash] =
            (selectedModStats[stat.statTypeHash] ?? 0) + stat.value;
      });
    });

    this.selectedModStats = selectedModStats;
    this.modStats = modStats;
    setState(() {});
  }

  List<DestinyItemSocketState> get socketStates =>
      widget.profile.getItemSockets(item.itemInstanceId);
}

class ItemStatWidget extends StatelessWidget {
  final DestinyInventoryItemStatDefinition definition;
  final int equippedModValue;
  final int selectedModValue;

  ItemStatWidget(this.definition, this.equippedModValue, this.selectedModValue);
  @override
  Widget build(BuildContext context) {
    double totalWidth = MediaQuery.of(context).size.width - 32;
    print("$baseBarSize $modBarSize");
    return Container(
        padding: EdgeInsets.symmetric(vertical: 1),
        child: Row(children: [
          SizedBox(
              width: totalWidth * .45,
              child: ManifestText<DestinyStatDefinition>(
                definition.statHash,
                textAlign: TextAlign.right,
                uppercase: true,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 12),
                overflow: TextOverflow.fade,
              )),
          SizedBox(
              width: totalWidth * .1,
              child: Text(
                "${definition.value + modValue}",
                textAlign: TextAlign.center,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                    color: modColor, fontWeight: FontWeight.bold, fontSize: 12),
                overflow: TextOverflow.fade,
              )),
          noBar
              ? Container()
              : Expanded(
                  child: Container(
                      color: Colors.grey.shade600,
                      height: 8,
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        direction: Axis.horizontal,
                        children: [
                        FractionallySizedBox(
                          widthFactor: definition.value / 100,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            height:8,
                            color: color,
                          ),
                        ),
                        modBarSize != 0 ? FractionallySizedBox(widthFactor: (modBarSize.abs())/100,
                        alignment: Alignment.centerLeft,
                        child: Container(
                            height:8,
                            color: modColor,
                          ),) : Container()
                      ])))
        ]));
  }

  int get baseBarSize{
    if(modBarSize < 0){
      return definition.value + modBarSize;
    }
    return definition.value;
  }

  int get modValue{
    if(selectedModValue != null){
      return selectedModValue;
    }
    return equippedModValue ?? 0;
  }

  int get modBarSize{
    int equipped = equippedModValue ?? 0;
    int selected = selectedModValue ?? equipped;
    if(equipped != selected){
      return (equipped - selected).abs();
    }
    return equipped;
  }

  Color get modColor{
    int equipped = equippedModValue ?? 0;
    int selected = selectedModValue ?? equipped;
    if(equipped == selected){
      return color;
    }
    if(equipped > selected){
      return DestinyData.negativeFeedback;
    }
    
    return DestinyData.positiveFeedback;
  }



  Color get color {
    return hiddenStat ? Colors.amber.shade300 : Colors.grey.shade300;
  }

  bool get hiddenStat {
    return _hiddenStats.contains(definition.statHash);
  }

  bool get noBar {
    return _noBarStats.contains(definition.statHash);
  }
}
