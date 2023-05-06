import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/littlelight_data/littlelight_data.bloc.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/progress/widgets/milestone_activity_select.bottomsheet.dart';
import 'package:little_light/modules/progress/widgets/milestone_item_modifiers.widget.dart';
import 'package:little_light/modules/progress/widgets/milestone_item_phases.widget.dart';
import 'package:little_light/modules/progress/widgets/milestone_item_rewards.widget.dart';
import 'package:little_light/modules/progress/widgets/milestone_modifiers.bottomsheet.dart';
import 'package:little_light/modules/progress/widgets/milestone_rewards.bottomsheet.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/blocs/scoped_value_repository/page_storage_helper.dart';
import 'package:little_light/shared/widgets/objectives/objective.widget.dart';
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
            Expanded(child: SizedBox()),
            buildModifiers(context, def),
            buildPhases(context, def),
            buildChallenges(context, def),
            buildQuestsInfo(context, def),
            buildRewards(context),
            buildActivities(context, def),
          ].whereType<Widget>().toList(),
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

  Widget? buildQuestsInfo(BuildContext context, DestinyMilestoneDefinition? def) {
    final quests = milestone.availableQuests;
    if (quests == null || quests.isEmpty) return null;
    return Column(
      children: [
        for (final quest in quests) buildQuest(context, quest),
      ],
    );
  }

  Widget buildQuest(BuildContext context, DestinyMilestoneQuest quest) {
    final challengeObjectives = quest.challenges?.map((e) => e.objective).whereType<DestinyObjectiveProgress>() ?? [];
    final stepObjectives = quest.status?.stepObjectives ?? [];
    return Container(
        margin: EdgeInsets.only(top: 2),
        decoration: BoxDecoration(
          color: context.theme.surfaceLayers.layer0.withOpacity(.8),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: EdgeInsets.all(4),
        child: Column(
          children: [
            ...challengeObjectives.map(
              (objective) => buildQuestObjective(context, objective),
            ),
            ...stepObjectives.map(
              (objective) => buildQuestObjective(context, objective),
            ),
          ],
        ));
  }

  Widget buildQuestObjective(BuildContext context, DestinyObjectiveProgress objective) {
    final objectiveHash = objective.objectiveHash;
    if (objectiveHash == null) return Container();
    return ObjectiveWidget(
      objectiveHash,
      objective: objective,
    );
  }

  Widget? buildActivities(BuildContext context, DestinyMilestoneDefinition? def) {
    final activities = def?.activities;
    final currentActivity = this.getSelectedActivity(context, def);
    if (activities == null || activities.length <= 1 || currentActivity == null) return null;
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

  Widget? buildPhases(BuildContext context, DestinyMilestoneDefinition? def) {
    final activityHash = getSelectedActivity(context, def);
    final defActivity = def?.activities?.firstWhereOrNull((a) => a.activityHash == activityHash);
    final phases = defActivity?.phases;
    if (phases == null) return Container();
    final milestoneActivity = milestone.activities //
        ?.firstWhereOrNull((element) => element.activityHash == activityHash);
    return MilestoneItemPhasesWidget(
      definitionPhases: phases,
      profilePhases: milestoneActivity?.phases,
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

  Widget? buildModifiers(BuildContext context, DestinyMilestoneDefinition? def) {
    final activityHash = getSelectedActivity(context, def);
    final activity = milestone.activities?.firstWhereOrNull((element) => element.activityHash == activityHash);
    final modifierHashes = activity?.modifierHashes
        ?.where((h) {
          final def = context.definition<DestinyActivityModifierDefinition>(h);
          final hasIcon = def?.displayProperties?.hasIcon ?? false;
          final hasName = def?.displayProperties?.name?.isNotEmpty ?? false;
          return hasIcon || hasName;
        })
        .toSet()
        .toList();
    if (activityHash == null || modifierHashes == null || modifierHashes.isEmpty) return null;
    return MilestoneItemModifiersWidget(
      modifierHashes,
      onTap: () => MilestoneModifiersBottomSheet(
        activityHash,
        modifierHashes.toList(),
      ).show(context),
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

  Widget? buildRewards(BuildContext context) {
    final rewards = milestone.rewards?.where((element) => element.entries?.isNotEmpty ?? false);
    if (rewards == null || rewards.isEmpty) return null;
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rewards //
            .map((reward) => buildRewardCategory(context, reward))
            .whereType<Widget>()
            .toList());
  }

  Widget? buildRewardCategory(BuildContext context, DestinyMilestoneRewardCategory reward) {
    final entries = reward.entries;
    final def = context.definition<DestinyMilestoneDefinition>(milestone.milestoneHash);
    final categoryDef = def?.rewards?["${reward.rewardCategoryHash}"];
    if (entries == null || entries.isEmpty || categoryDef == null) return null;
    return MilestoneItemRewardsCategoryWidget(
      entries: entries,
      categoryDefinition: categoryDef,
      onTap: () => MilestoneRewardsBottomSheet(entries, categoryDef).show(context),
    );
  }
}
