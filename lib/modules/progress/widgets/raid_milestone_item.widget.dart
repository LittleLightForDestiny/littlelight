import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

class RaidMilestoneItemWidget extends StatelessWidget with ManifestConsumer {
  final DestinyMilestone milestone;
  const RaidMilestoneItemWidget(this.milestone, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hash = milestone.milestoneHash;
    if (hash == null) return Container();
    return DefinitionProviderWidget<DestinyMilestoneDefinition>(hash, (def) => buildWithDefinition(context, def));
  }

  Widget buildWithDefinition(BuildContext context, DestinyMilestoneDefinition? def) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(child: buildBackground(context, def)),
            buildForeground(context, def),
          ],
        ));
  }

  Widget buildForeground(BuildContext context, DestinyMilestoneDefinition? def) {
    return Container(
        padding: EdgeInsets.all(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildMilestoneHeader(context, def),
            buildActivities(context, def),
            buildPhases(context, def),
          ],
        ));
  }

  Widget buildMilestoneHeader(BuildContext context, DestinyMilestoneDefinition? def) {
    String? iconUrl = def?.displayProperties?.icon;
    iconUrl ??= def?.quests?.values.firstWhereOrNull((q) => q.displayProperties?.icon != null)?.displayProperties?.icon;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (iconUrl != null)
          Container(
            decoration: BoxDecoration(
                gradient: RadialGradient(
              colors: [
                context.theme.surfaceLayers.layer2,
                context.theme.surfaceLayers.layer2.withOpacity(0),
              ],
              stops: [.2, 1],
            )),
            width: 64,
            height: 64,
            child: QueuedNetworkImage.fromBungie(iconUrl),
          ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(4),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(4), color: context.theme.surfaceLayers.layer2),
                child: Text(def?.displayProperties?.name?.toUpperCase() ?? "",
                    style: context.textTheme.itemNameHighDensity),
              ),
              Flexible(child: SizedBox(height: 2)),
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4), color: context.theme.surfaceLayers.layer0.withOpacity(.8)),
                child: Text(def?.displayProperties?.description ?? "", style: context.textTheme.body),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget buildActivities(BuildContext context, DestinyMilestoneDefinition? def) {
    final activities = def?.activities;
    if (activities == null || activities.length <= 1) return SizedBox();
    return Column(
      children: activities.map((e) {
        final hash = e.activityHash;
        if (hash == null) return Container();
        return DefinitionProviderWidget<DestinyActivityDefinition>(
            hash, (definition) => buildActivity(context, definition));
      }).toList(),
    );
  }

  Widget buildActivity(BuildContext context, DestinyActivityDefinition? definition) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: context.theme.surfaceLayers.layer2),
      child:
          Text(definition?.displayProperties?.name?.toUpperCase() ?? "", style: context.textTheme.itemNameHighDensity),
    );
  }

  Widget buildBackground(BuildContext context, DestinyMilestoneDefinition? def) {
    return FutureBuilder<String?>(
        future: getBackgroundImageUrl(context, def),
        builder: (context, snapshot) {
          if (snapshot.data == null)
            return Container(
              color: context.theme.surfaceLayers.layer1,
            );
          return QueuedNetworkImage.fromBungie(
            snapshot.data,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          );
        });
  }

  Widget buildPhases(BuildContext context, DestinyMilestoneDefinition? def) {
    final defActivity = def?.activities?.firstOrNull;
    if (defActivity == null) return Container();
    final phases = defActivity.phases;
    if (phases == null) return Container();
    final milestoneActivity = milestone.activities //
        ?.firstWhereOrNull((element) => element.activityHash == defActivity.activityHash);
    final finishedPhases = milestoneActivity?.phases //
        ?.map((e) => (e.complete ?? false) ? e.phaseHash : null)
        .whereType<int>()
        .toSet();
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: IntrinsicWidth(
            child: Container(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: Row(
            children: phases.mapIndexed(
              (index, element) {
                final phaseHash = element.phaseHash;
                final completed = index < 2 || (finishedPhases?.contains(phaseHash) ?? false);
                return Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color:
                          completed ? context.theme.secondarySurfaceLayers.layer1 : context.theme.surfaceLayers.layer2,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Text(
                      getPhaseName(context, phaseHash, index),
                      style: context.textTheme.button.copyWith(
                        color: completed ? context.theme.upgradeLayers.layer0 : context.theme.onSurfaceLayers.layer0,
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        )),
      ),
    );
  }

  String getPhaseName(BuildContext context, int? phaseHash, int index) {
    return "Phase {phase}".translate(context, replace: {"phase": "${index + 1}"});
  }

  Future<String?> getBackgroundImageUrl(BuildContext context, DestinyMilestoneDefinition? def) async {
    final validImageReg = RegExp(r"\..*$");
    final url = def?.image;
    final isValid = url != null && validImageReg.hasMatch(url);
    if (isValid) return url;
    final activities = def?.activities;
    if (activities == null) return null;
    for (final activity in activities) {
      final hash = activity.activityHash;
      final activityDef = await manifest.getDefinition<DestinyActivityDefinition>(hash);
      final url = activityDef?.pgcrImage;
      final isValid = url != null && validImageReg.hasMatch(url);
      if (isValid) return url;
    }
    return null;
  }
}
