// @dart=2.9

import 'package:bungie_api/models/destiny_lore_definition.dart';
import 'package:bungie_api/models/destiny_metric_component.dart';
import 'package:bungie_api/models/destiny_metric_definition.dart';
import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:bungie_api/models/destiny_trait_definition.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:little_light/models/tracked_objective.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/services/littlelight/objectives.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

class MetricItemWidget extends StatefulWidget {
  final int presentationNodeHash;
  const MetricItemWidget({Key key, this.presentationNodeHash}) : super(key: key);

  @override
  MetricItemWidgetState createState() {
    return MetricItemWidgetState();
  }
}

class MetricItemWidgetState extends State<MetricItemWidget> with AuthConsumer, ProfileConsumer, ManifestConsumer {
  DestinyMetricDefinition _definition;
  Map<int, DestinyObjectiveDefinition> objectiveDefinitions;
  DestinyLoreDefinition loreDefinition;
  bool isTracking = false;

  DestinyMetricDefinition get definition {
    return manifest.getDefinitionFromCache<DestinyMetricDefinition>(widget.presentationNodeHash) ?? _definition;
  }

  DestinyMetricComponent get metric {
    return profile.getMetric(definition?.hash);
  }

  @override
  void initState() {
    super.initState();
    loadDefinitions();
    updateTrackStatus();
  }

  updateTrackStatus() async {
    var objectives = await ObjectivesService().getTrackedObjectives();
    var tracked = objectives.firstWhere(
        (o) => o.hash == widget.presentationNodeHash && o.type == TrackedObjectiveType.Triumph,
        orElse: () => null);
    isTracking = tracked != null;
    if (!mounted) return;
    setState(() {});
  }

  loadDefinitions() async {
    if (definition == null) {
      _definition = await manifest.getDefinition<DestinyMetricDefinition>(widget.presentationNodeHash);
      if (!mounted) return;
      setState(() {});
    }
    // if (definition?.objectiveHashes != null) {
    //   objectiveDefinitions =
    //       await manifest.getDefinitions<DestinyObjectiveDefinition>(
    //           definition.objectiveHashes);
    //   if (mounted) setState(() {});
    // }

    // if (definition?.loreHash != null) {
    //   loreDefinition = await manifest
    //       .getDefinition<DestinyLoreDefinition>(definition.loreHash);
    //   if (mounted) setState(() {});
    // }
  }

  Color get foregroundColor {
    return Colors.grey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: foregroundColor, width: 1),
        ),
        child: Row(children: [Expanded(child: buildContent(context)), buildBadge(context)]));
  }

  Widget buildBadge(BuildContext context) {
    if (definition == null) return Container();
    List<Widget> icons = [];
    for (var t in definition.traitHashes) {
      if (t != 1434215347) {
        icons.add(ManifestImageWidget<DestinyTraitDefinition>(t));
      }
    }
    icons.add(QueuedNetworkImage(imageUrl: BungieApiService.url(definition?.displayProperties?.icon)));
    return Container(
        width: 28,
        margin: const EdgeInsets.only(right: 8),
        alignment: Alignment.center,
        child: Stack(children: [
          Positioned(
              top: 0,
              bottom: 8,
              child: ManifestImageWidget<DestinyPresentationNodeDefinition>(definition.parentNodeHashes[0])),
          Positioned(left: 2, right: 2, bottom: 20, child: Column(children: icons))
        ]));
  }

  buildContent(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [buildTitle(context), buildObjective(context), Expanded(child: buildDescription(context))]));
  }

  buildTitle(BuildContext context) {
    if (definition == null) return Container();
    return Container(
        child: Text(
      definition.displayProperties.name,
      softWrap: false,
      overflow: TextOverflow.fade,
      style: TextStyle(color: foregroundColor),
    ));
  }

  buildDescription(BuildContext context) {
    if (definition == null) return Container();
    if ((definition?.displayProperties?.description?.length ?? 0) == 0) return Container();

    return Container(
        alignment: Alignment.bottomLeft,
        child: Text(
          definition.displayProperties.description.replaceAll("\n\n", "\n"),
          softWrap: true,
          overflow: TextOverflow.fade,
          style: TextStyle(color: foregroundColor, fontWeight: FontWeight.w300, fontSize: 13),
        ));
  }

  buildObjective(BuildContext context) {
    if (metric.objectiveProgress.progress == null) return Container();

    var formatter = NumberFormat.decimalPattern(context.currentLanguage);
    var formattedProgress = formatter.format(metric.objectiveProgress.progress);
    return Text(formattedProgress, style: const TextStyle(fontSize: 18));
  }
}
