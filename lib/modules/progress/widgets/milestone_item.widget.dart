import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/littlelight_data/littlelight_data.bloc.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/progress/widgets/milestone_activity_select.bottomsheet.dart';
import 'package:little_light/modules/progress/widgets/milestone_modifiers.bottomsheet.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/blocs/scoped_value_repository/page_storage_helper.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/generic_progress_bar.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/icon_fonts/littlelight_icons.dart';
import 'package:provider/provider.dart';

class SelectedActivityKey extends StorableValue<int> {
  SelectedActivityKey(Key key, [int? value]) : super(key, value);
}

class MilestoneItemWidget extends StatelessWidget with ManifestConsumer {
  final DestinyMilestone milestone;
  final DestinyCharacterInfo? character;
  const MilestoneItemWidget(this.milestone, {this.character, Key? key}) : super(key: key);

  int? getSelectedActivity(BuildContext context, DestinyMilestoneDefinition? def) {
    final key = this.key;
    if (key == null) return def?.activities?.firstOrNull?.activityHash;
    final hash = context.readValue(SelectedActivityKey(key))?.value;
    return hash ?? def?.activities?.firstOrNull?.activityHash;
  }

  @override
  Widget build(BuildContext context) {
    final milestoneHash = milestone.milestoneHash;
    final def = context.definition<DestinyMilestoneDefinition>(milestoneHash);
    if (def == null) return Container();
    return buildWithDefinition(context, def);
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildMilestoneHeader(context, def),
            buildModifiers(context, def),
            buildPhases(context, def),
            buildChallenges(context, def),
            buildActivities(context, def),
          ],
        ));
  }

  Widget buildMilestoneHeader(BuildContext context, DestinyMilestoneDefinition? def) {
    String? iconUrl = def?.displayProperties?.icon;
    iconUrl ??= def?.quests?.values.firstWhereOrNull((q) => q.displayProperties?.icon != null)?.displayProperties?.icon;
    if (def?.displayProperties?.name?.toLowerCase().startsWith('shady') ?? false) {
      //TODO: use breakpoint here to check how to present milestone completion info
      print('ding!');
    }
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
                child: ManifestText<DestinyMilestoneDefinition>(
                  milestone.milestoneHash,
                  textExtractor: (def) => def.displayProperties?.description,
                  style: context.textTheme.body,
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget buildActivities(BuildContext context, DestinyMilestoneDefinition? def) {
    final activities = def?.activities;
    final currentActivity = this.getSelectedActivity(context, def);
    if (activities == null || activities.length <= 1 || currentActivity == null) return SizedBox();
    return DefinitionProviderWidget<DestinyActivityDefinition>(currentActivity, (definition) {
      final name = definition?.selectionScreenDisplayProperties?.name ?? definition?.displayProperties?.name;
      return Container(
        margin: EdgeInsets.only(top: 4),
        child: Material(
          color: context.theme.surfaceLayers.layer2,
          borderRadius: BorderRadius.circular(4),
          child: InkWell(
            onTap: () async {
              final hashes = activities.map((a) => a.activityHash).whereType<int>().toList();
              final selected = await MilestoneActivitySelectBottomSheet(hashes).show(context);
              final key = this.key;
              if (key == null) return;
              if (selected != null) {
                context.storeValue(SelectedActivityKey(key, selected));
              }
            },
            child: Container(
              padding: EdgeInsets.all(8),
              child: Row(children: [
                Expanded(child: Text(name?.toUpperCase() ?? "", style: context.textTheme.itemNameHighDensity)),
                Container(
                    child: Icon(
                  LittleLightIcons.power,
                  size: 8,
                  color: context.theme.achievementLayers,
                )),
                Text(
                  "${definition?.activityLightLevel}",
                  style: context.textTheme.button.copyWith(
                    color: context.theme.achievementLayers,
                  ),
                ),
                SizedBox(width: 8),
                Icon(FontAwesomeIcons.caretDown, size: 12),
              ]),
            ),
          ),
        ),
      );
    });
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
    final activityHash = getSelectedActivity(context, def);
    final defActivity = def?.activities?.firstWhereOrNull((a) => a.activityHash == activityHash);
    if (activityHash == null) return Container();
    final phases = defActivity?.phases;
    if (phases == null) return Container();
    final milestoneActivity = milestone.activities //
        ?.firstWhereOrNull((element) => element.activityHash == activityHash);
    final finishedPhases = milestoneActivity?.phases //
        ?.map((e) => (e.complete ?? false) ? e.phaseHash : null)
        .whereType<int>()
        .toSet();
    return Container(
      margin: EdgeInsets.only(top: 8),
      height: 40,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          controller: ScrollController(keepScrollOffset: false, initialScrollOffset: 0),
          scrollDirection: Axis.horizontal,
          child: IntrinsicWidth(
            child: Container(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Row(
                children: phases.mapIndexed(
                  (index, element) {
                    final phaseHash = element.phaseHash;
                    final completed = finishedPhases?.contains(phaseHash) ?? false;
                    return Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: completed
                              ? context.theme.secondarySurfaceLayers.layer1
                              : context.theme.surfaceLayers.layer2,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        child: Text(
                          getPhaseName(context, phaseHash, index),
                          textAlign: TextAlign.center,
                          style: context.textTheme.button.copyWith(
                            color:
                                completed ? context.theme.upgradeLayers.layer0 : context.theme.onSurfaceLayers.layer3,
                          ),
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildChallenges(BuildContext context, DestinyMilestoneDefinition? def) {
    final activityHash = getSelectedActivity(context, def);
    final activity = milestone.activities?.firstWhereOrNull((element) => element.activityHash == activityHash);
    final challenges = activity?.challenges;
    if (challenges == null || challenges.isEmpty) return Container();
    return Container(
        margin: EdgeInsets.only(top: 2),
        decoration: BoxDecoration(
          color: context.theme.surfaceLayers.layer0.withOpacity(.8),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: EdgeInsets.all(4),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: challenges
                .map((e) => GenericProgressBarWidget(
                      completed: e.objective?.complete,
                      progress: e.objective?.progress,
                      total: e.objective?.completionValue,
                      description: ManifestText<DestinyObjectiveDefinition>(
                        e.objective?.objectiveHash,
                        textExtractor: (def) {
                          return def.progressDescription ?? def.displayProperties?.name ?? "";
                        },
                      ),
                    ))
                .toList()));
  }

  Widget buildModifiers(BuildContext context, DestinyMilestoneDefinition? def) {
    final activityHash = getSelectedActivity(context, def);
    final activity = milestone.activities?.firstWhereOrNull((element) => element.activityHash == activityHash);
    final modifierHashes = activity?.modifierHashes?.toSet();
    if (activityHash == null || modifierHashes == null || modifierHashes.isEmpty) return Container();
    return Container(
      margin: EdgeInsets.only(top: 2),
      child: Material(
        child: InkWell(
          onTap: () => MilestoneModifiersBottomSheet(activityHash, modifierHashes.toList()).show(context),
          child: Container(
            decoration: BoxDecoration(
              color: context.theme.surfaceLayers.layer0.withOpacity(.8),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: EdgeInsets.all(4),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Container(
                margin: EdgeInsets.only(bottom: 4),
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: context.theme.surfaceLayers.layer2,
                ),
                child: Text(
                  "Modifiers".translate(context).toUpperCase(),
                  style: context.textTheme.button,
                ),
              ),
              Row(
                children: modifierHashes
                    .map(
                      (e) {
                        final def = context.definition<DestinyActivityModifierDefinition>(e);
                        final hasIcon = def?.displayProperties?.hasIcon ?? false;
                        if (!hasIcon) return null;
                        return Container(
                          width: 24,
                          height: 24,
                          child: ManifestImageWidget<DestinyActivityModifierDefinition>(e),
                          margin: EdgeInsets.only(right: 4),
                        );
                      },
                    )
                    .whereType<Widget>()
                    .toList(),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  String getPhaseName(BuildContext context, int? phaseHash, int index) {
    final name = context.watch<LittleLightDataBloc>().gameData?.raidPhases?["$phaseHash"];
    if (name != null) return name.translate(context).split(" ").join("\n");
    return "Phase {phase}".translate(context, replace: {"phase": "${index + 1}"});
  }

  Future<String?> getBackgroundImageUrl(BuildContext context, DestinyMilestoneDefinition? def) async {
    final validImageReg = RegExp(r"\..*$");
    final url = def?.image;
    final isValid = url != null && validImageReg.hasMatch(url);
    if (isValid) return url;
    final activities = def?.activities ?? [];

    for (final activity in activities) {
      final hash = activity.activityHash;
      final activityDef = await manifest.getDefinition<DestinyActivityDefinition>(hash);
      final url = activityDef?.pgcrImage;
      final isValid = url != null && validImageReg.hasMatch(url);
      if (isValid) return url;
    }

    final quests = def?.quests?.values ?? [];

    for (final quest in quests) {
      final questDef = await manifest.getDefinition<DestinyInventoryItemDefinition>(quest.questItemHash);
      final setDataItems = questDef?.setData?.itemList ?? [];
      for (final setDataItem in setDataItems) {
        final setDataItemDef = await manifest.getDefinition<DestinyInventoryItemDefinition>(setDataItem.itemHash);
        if (setDataItemDef?.secondaryIcon != null) return setDataItemDef?.secondaryIcon;
      }
    }

    return null;
  }
}
