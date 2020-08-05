import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateful_item.widget.dart';

class BaseMasterworkCounterWidget extends BaseDestinyStatefulItemWidget {
  BaseMasterworkCounterWidget({DestinyItemComponent item, Key key})
      : super(item: item, key: key);

  @override
  State<StatefulWidget> createState() {
    return BaseMasterworkCounterWidgetState();
  }
}

class BaseMasterworkCounterWidgetState<T extends BaseMasterworkCounterWidget>
    extends BaseDestinyItemState<T>
    with AutomaticKeepAliveClientMixin {
  DestinyObjectiveProgress masterworkObjective;
  DestinyObjectiveDefinition masterworkObjectiveDefinition;

  initState() {
    super.initState();
    loadDefinitions();
  }

  loadDefinitions() async {
    if (widget.item == null) return;
    var plugObjectives =
        widget.profile.getPlugObjectives(widget?.item?.itemInstanceId);
    if(plugObjectives == null) return;
    for (var objectives in plugObjectives?.values) {
      for (var objective in objectives) {
        if (objective.visible) {
          masterworkObjective = objective;
          masterworkObjectiveDefinition = await widget.manifest
              .getDefinition<DestinyObjectiveDefinition>(
                  objective.objectiveHash);
        }
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (this.masterworkObjective == null ||
        this.masterworkObjectiveDefinition?.displayProperties?.icon == null) {
      return Container();
    }
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            buildIcon(context),
            Container(
              width: 4,
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                buildProgressDescription(context),
                Container(
                  width: 4,
                ),
                buildProgressValue(context)
              ],
            ))
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;

  Widget buildIcon(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      child: Image(
          image: AdvancedNetworkImage(BungieApiService.url(
              masterworkObjectiveDefinition.displayProperties.icon))),
    );
  }

  Widget buildProgressDescription(BuildContext context) {
    return Text(masterworkObjectiveDefinition.progressDescription,
        softWrap: false,
        overflow: TextOverflow.fade,
        style: TextStyle(color: Colors.white, fontSize: 11));
  }

  Widget buildProgressValue(BuildContext context) {
    return Text("${masterworkObjective.progress}",
        style: TextStyle(color: Colors.amber.shade200, fontSize: 15));
  }
}
