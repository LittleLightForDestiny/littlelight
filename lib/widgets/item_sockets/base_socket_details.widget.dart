import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_investment_stat_definition.dart';
import 'package:bungie_api/models/destiny_item_plug.dart';
import 'package:bungie_api/models/destiny_item_socket_category_definition.dart';
import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/models/tracked_objective.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/littlelight/objectives.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateful_item.widget.dart';
import 'package:little_light/widgets/common/objective.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/item_details/item_stats.widget.dart';

class BaseSocketDetailsWidget extends BaseDestinyStatefulItemWidget {
  final ManifestService manifest = ManifestService();
  final DestinyItemPlug plug;
  final DestinyItemSocketCategoryDefinition category;

  BaseSocketDetailsWidget(
      {Key key,
      DestinyInventoryItemDefinition definition,
      DestinyItemComponent item,
      this.category,
      this.plug})
      : super(key: key, item: item, definition: definition); 

  @override
  State<StatefulWidget> createState() {
    return BaseSocketDetailsWidgetState();
  }
}

class BaseSocketDetailsWidgetState<T extends BaseSocketDetailsWidget> extends BaseDestinyItemState<T>
    with TickerProviderStateMixin {
  bool isTracking = false;
  
  Map<int, DestinyObjectiveDefinition> objectiveDefinitions;
  bool open = false;

  @override
  void initState() {
    super.initState();
    loadDefinitions();
    updateTrackStatus();
  }

  Future<void> loadDefinitions() async {
    if ((definition?.objectives?.objectiveHashes?.length ?? 0) > 0) {
      objectiveDefinitions = await widget.manifest
          .getDefinitions<DestinyObjectiveDefinition>(
              definition.objectives.objectiveHashes);
    }

    if (mounted) {
        setState(() {});
      }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: Colors.blueGrey.shade700,
            borderRadius: BorderRadius.circular(8)),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                  child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 32,
                    height: 32,
                    child: QueuedNetworkImage(
                      imageUrl: BungieApiService.url(
                          definition?.displayProperties?.icon),
                    ),
                  ),
                  Container(
                    width: 8,
                  ),
                  Expanded(
                      child: Text(
                    definition?.displayProperties?.name ?? "",
                    softWrap: true,
                    overflow: TextOverflow.fade,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                ],
              )),
            ],
          ),
          AnimatedCrossFade(
              crossFadeState:
                  open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              alignment: Alignment.topCenter,
              duration: Duration(milliseconds: 300),
              firstChild: Container(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                      padding: EdgeInsets.all(4),
                      child: Text(
                        definition?.displayProperties?.description ?? "",
                      )),
                  buildStats(context),
                  buildObjectives(
                    context,
                  ),
                ],
              )),
        ]));
  }

  buildExpandButton(BuildContext context) {
    // if (widget.alwaysOpen) return Container();
    return Stack(children: [
      Container(
          width: 25,
          height: 25,
          alignment: Alignment.center,
          child: Icon(
              open ? FontAwesomeIcons.minusCircle : FontAwesomeIcons.plusCircle,
              size: 18)),
      Positioned.fill(
          child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  open = !open;
                  setState(() {});
                },
              )))
    ]);
  }

  buildStats(BuildContext context) {
    List<DestinyItemInvestmentStatDefinition> stats =
        definition?.investmentStats;

    if (stats == null || stats.length == 0) {
      return Container();
    }

    List<Widget> statList = stats.map<Widget>((stat) {
      var values = StatValues();
      values.selected = stat.value;
      return ItemStatWidget(stat.statTypeHash, 0, values);
    }).toList();
    return Container(
        color: Colors.blueGrey.shade900,
        margin: EdgeInsets.all(4),
        child: Column(children: [
          Container(
              constraints: BoxConstraints(minWidth: double.infinity),
              color: Colors.black,
              alignment: Alignment.center,
              padding: EdgeInsets.all(4),
              child: TranslatedTextWidget("Stats",
                  uppercase: true,
                  style: TextStyle(fontWeight: FontWeight.w700))),
          Container(
              padding: EdgeInsets.all(8),
              child: Column(
                children: statList,
              ))
        ]));
  }

  Widget buildObjectives(BuildContext context) {
    if ((definition?.objectives?.objectiveHashes?.length ?? 0) == 0) {
      return Container();
    }
    List<Widget> children =
        definition.objectives.objectiveHashes.map<Widget>((hash) {
      var objective = getObjective(hash);
      if (!(objective?.visible ?? false)) return Container();
      return ObjectiveWidget(
        definition: getObjectiveDefinition(hash),
        objective: objective,
        placeholder: definition?.displayProperties?.name ?? "",
      );
    }).toList();
    return Container(
        // padding: EdgeInsets.all(8),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children));
  }

  updateTrackStatus() async {
    var objectives = await ObjectivesService().getTrackedObjectives();
    var tracked = objectives.firstWhere(
        (o) =>
            o?.hash == widget?.definition?.hash &&
            o?.type == TrackedObjectiveType.Plug &&
            (o?.instanceId == null) &&
            o?.characterId == null,
        orElse: () => null);
    isTracking = tracked != null;
    if (!mounted) return;
    setState(() {});
  }

  DestinyObjectiveDefinition getObjectiveDefinition(int hash) {
    if (objectiveDefinitions == null) return null;
    return objectiveDefinitions[hash];
  }

  DestinyObjectiveProgress getObjective(hash) {
    if (widget.plug?.plugObjectives == null) return null;
    return widget.plug?.plugObjectives
        ?.firstWhere((o) => o.objectiveHash == hash, orElse: () => null);
  }
}
