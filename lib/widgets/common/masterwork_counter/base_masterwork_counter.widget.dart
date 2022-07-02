import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

class BaseMasterworkCounterWidget extends StatefulWidget {
  final DestinyItemComponent? item;

  BaseMasterworkCounterWidget({this.item, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BaseMasterworkCounterWidgetState();
  }
}

class BaseMasterworkCounterWidgetState<T extends BaseMasterworkCounterWidget> extends State<T>
    with AutomaticKeepAliveClientMixin, ProfileConsumer, ManifestConsumer {
  DestinyObjectiveProgress? masterworkObjective;
  DestinyObjectiveDefinition? masterworkObjectiveDefinition;

  initState() {
    super.initState();
    loadDefinitions();
  }

  loadDefinitions() async {
    final itemInstanceID = widget.item?.itemInstanceId;
    if (itemInstanceID == null) return;
    final plugObjectives = profile.getPlugObjectives(itemInstanceID);

    if (plugObjectives == null) return;
    for (final objectives in plugObjectives.values) {
      for (final objective in objectives) {
        if (objective.visible ?? false) {
          masterworkObjective = objective;
          masterworkObjectiveDefinition =
              await manifest.getDefinition<DestinyObjectiveDefinition>(objective.objectiveHash);
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
    if (this.masterworkObjective == null || this.masterworkObjectiveDefinition?.displayProperties?.icon == null) {
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
      child: QueuedNetworkImage.fromBungie(masterworkObjectiveDefinition?.displayProperties?.icon),
    );
  }

  Widget buildProgressDescription(BuildContext context) {
    final description = masterworkObjectiveDefinition?.progressDescription;
    if (description == null) return Container();
    return Text(description,
        softWrap: false,
        overflow: TextOverflow.fade,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 11));
  }

  Widget buildProgressValue(BuildContext context) {
    var formatter = NumberFormat.decimalPattern(context.currentLanguage);
    var formattedValue = formatter.format(masterworkObjective?.progress ?? 0);
    return Text("$formattedValue", style: TextStyle(color: Colors.amber.shade200, fontSize: 15));
  }
}
