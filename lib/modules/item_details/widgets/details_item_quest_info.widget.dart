import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/item_info/definition_item_info.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/models/tracked_objective.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/blocs/scoped_value_repository/page_storage_helper.dart';
import 'package:little_light/shared/utils/extensions/tier_type_data.dart';
import 'package:little_light/shared/widgets/containers/persistent_collapsible_container.dart';
import 'package:little_light/shared/widgets/inventory_item/inventory_item_icon.dart';
import 'package:little_light/shared/widgets/objectives/objective.widget.dart';
import 'package:little_light/shared/widgets/objectives/track_objectives.button.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

class _VisibleState extends StorableValue<bool> {
  _VisibleState(String key, [bool? value]) : super(key, value);
}

const _animationDuration = const Duration(milliseconds: 300);

class DetailsItemQuestInfoWidget extends StatelessWidget {
  final DestinyItemInfo itemInfo;

  const DetailsItemQuestInfoWidget(
    this.itemInfo, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(4),
        child: PersistentCollapsibleContainer(
          title: Text("Quest steps".translate(context).toUpperCase()),
          persistenceID: 'item quest steps',
          content: buildContent(context),
        ));
  }

  Widget buildContent(
    BuildContext context,
  ) {
    return Container(
      child: Column(
          children: [
        buildQuestline(context),
        buildPreviousQuestSteps(context),
        buildCurrentQuestStep(context),
        buildNextQuestSteps(context),
      ].whereType<Widget>().toList()),
    );
  }

  Widget? buildPreviousQuestSteps(BuildContext context) {
    final def = context.definition<DestinyInventoryItemDefinition>(itemInfo.itemHash);
    final questlineDef = context.definition<DestinyInventoryItemDefinition>(def?.objectives?.questlineItemHash);
    final questsSteps = questlineDef?.setData?.itemList;
    if (questsSteps == null) return null;
    final currentStepIndex = questsSteps.indexWhere((element) => itemInfo.itemHash == element.itemHash);
    if (currentStepIndex <= 0) return null;
    final visibilityKey = 'previous steps';
    final isOpen = context.readValue(_VisibleState(visibilityKey))?.value ?? false;
    if (!isOpen) {
      return buildSection(context,
          content: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: def?.inventory?.tierType?.getColor(context)),
            onPressed: () => context.storeValue(_VisibleState(visibilityKey, true)),
            child: Text(
              'Show previous steps ({stepCount})'.translate(context, replace: {'stepCount': "$currentStepIndex"}),
            ),
          ));
    }
    final items = questsSteps.take(currentStepIndex).map((qs) => qs.itemHash);

    return buildSection(
      context,
      title: Text("Previous steps".translate(context)),
      content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: def?.inventory?.tierType?.getColor(context)),
              onPressed: () => context.storeValue(_VisibleState(visibilityKey, false)),
              child: Text(
                'Hide previous steps'.translate(context),
              ),
            ),
            ...items.map((item) => Container(
                  margin: EdgeInsets.only(top: 4),
                  child: buildQuestStep(context, item, forceObjectivesCompletion: true),
                )),
          ].whereType<Widget>().toList()),
    );
  }

  Widget? buildNextQuestSteps(BuildContext context) {
    final def = context.definition<DestinyInventoryItemDefinition>(itemInfo.itemHash);
    final questlineDef = context.definition<DestinyInventoryItemDefinition>(def?.objectives?.questlineItemHash);
    final questsSteps = questlineDef?.setData?.itemList;
    if (questsSteps == null) return null;
    final currentStepIndex = questsSteps.indexWhere((element) => itemInfo.itemHash == element.itemHash);
    final questStepsCount = questsSteps.length;
    if (currentStepIndex >= questStepsCount - 1) return null;
    final visibilityKey = 'next steps';
    final isOpen = context.readValue(_VisibleState(visibilityKey))?.value ?? false;
    if (!isOpen) {
      return buildSection(context,
          content: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: def?.inventory?.tierType?.getColor(context)),
            onPressed: () => context.storeValue(_VisibleState(visibilityKey, true)),
            child: Text(
              'Show next steps ({stepCount})'
                  .translate(context, replace: {'stepCount': "${questStepsCount - currentStepIndex}"}),
            ),
          ));
    }
    final items = questsSteps.skip(currentStepIndex).map((qs) => qs.itemHash);

    return buildSection(
      context,
      title: Text("Next steps".translate(context)),
      content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: def?.inventory?.tierType?.getColor(context)),
              onPressed: () => context.storeValue(_VisibleState(visibilityKey, false)),
              child: Text(
                'Hide next steps'.translate(context),
              ),
            ),
            ...items.map((item) => Container(
                  margin: EdgeInsets.only(top: 4),
                  child: buildQuestStep(context, item),
                )),
          ].whereType<Widget>().toList()),
    );
  }

  Widget? buildCurrentQuestStep(BuildContext context) {
    final item = this.itemInfo;
    return buildSection(context,
        title: Text("Current step".translate(context)),
        content: buildQuestStep(
          context,
          item.itemHash,
          objectives: item.objectives?.objectives,
        ));
  }

  Widget? buildQuestStep(BuildContext context, int? itemHash,
      {bool forceObjectivesCompletion = false, List<DestinyObjectiveProgress>? objectives}) {
    final def = context.definition<DestinyInventoryItemDefinition>(itemHash);
    final questlineDef = context.definition<DestinyInventoryItemDefinition>(def?.objectives?.questlineItemHash);
    final totalSteps = questlineDef?.setData?.itemList?.length ?? 0;
    final currentStep = questlineDef?.setData?.itemList?.indexWhere((element) => element.itemHash == itemHash) ?? -1;
    if (def == null) return null;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: context.theme.surfaceLayers.layer1,
      ),
      child: Column(
        children: [
          Container(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(4),
                  color: def.inventory?.tierType?.getColor(context),
                  child: ManifestText<DestinyInventoryItemDefinition>(
                    itemHash,
                    uppercase: true,
                    style: context.textTheme.itemNameHighDensity,
                    textExtractor: (def) {
                      final questName = def.displayProperties?.name ?? "";
                      if (currentStep < 0 || totalSteps <= 1) return questName;
                      return "{questName} - Step {currentStep} of {totalSteps}".translate(context, replace: {
                        "questName": questName,
                        "currentStep": "${currentStep + 1}",
                        "totalSteps": "$totalSteps",
                      });
                    },
                  )),
              Container(
                padding: const EdgeInsets.all(8),
                child: ManifestText<DestinyInventoryItemDefinition>(
                  itemHash,
                  textExtractor: (d) => d.displayProperties?.description?.replaceAll('\n\n', '\n'),
                  style: context.textTheme.body,
                ),
              )
            ]),
          ),
          ...(def.objectives?.objectiveHashes?.map((objectiveHash) => buildQuestStepObjective(
                    context,
                    objectiveHash,
                    objectives: objectives,
                    forceCompletion: forceObjectivesCompletion,
                    placeholder: def.displayProperties?.description,
                  )) ??
              <Widget?>[])
        ].whereType<Widget>().toList(),
      ),
    );
  }

  Widget? buildQuestStepObjective(
    BuildContext context,
    int? objectiveHash, {
    List<DestinyObjectiveProgress>? objectives,
    bool forceCompletion = false,
    String? placeholder,
  }) {
    if (objectiveHash == null) return null;
    final objective = objectives?.firstWhere((element) => element.objectiveHash == objectiveHash);
    return Container(
        padding: EdgeInsets.all(4).copyWith(top: 0),
        child: ObjectiveWidget(
          objectiveHash,
          objective: objective,
          forceComplete: forceCompletion,
          placeholder: placeholder,
        ));
  }

  Widget? buildQuestline(BuildContext context) {
    final def = context.definition<DestinyInventoryItemDefinition>(this.itemInfo.itemHash);
    final questlineDef = context.definition<DestinyInventoryItemDefinition>(def?.objectives?.questlineItemHash);
    if (questlineDef == null) return null;

    final item = DefinitionItemInfo(questlineDef);
    return buildSection(context,
        title: Text(
          "From the questline".translate(context).toUpperCase(),
        ),
        content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: questlineDef.inventory?.tierType?.getColor(context),
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.all(4).copyWith(right: 8),
                      width: 48,
                      height: 48,
                      child: InventoryItemIcon(
                        item,
                        borderSize: 1,
                      ),
                    ),
                    Expanded(
                      child: ManifestText<DestinyInventoryItemDefinition>(
                        questlineDef.hash,
                        uppercase: true,
                        style: context.textTheme.itemNameHighDensity.copyWith(
                          color: questlineDef.inventory?.tierType?.getTextColor(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              buildTrackButton(context),
            ].whereType<Widget>().toList()));
  }

  Widget? buildTrackButton(BuildContext context) {
    final def = context.definition<DestinyInventoryItemDefinition>(this.itemInfo.itemHash);
    final questHash = def?.objectives?.questlineItemHash ?? this.itemInfo.itemHash;
    final characterId = this.itemInfo.characterId;
    if (questHash == null || characterId == null) return null;

    return Container(
      margin: EdgeInsets.only(top: 8),
      child: TrackObjectivesButton(
        TrackedObjectiveType.Questline,
        trackedHash: questHash,
        characterId: characterId,
      ),
    );
  }

  Widget buildSection(BuildContext context, {required Widget? content, Widget? title}) => AnimatedSize(
      duration: _animationDuration,
      child: Container(
        decoration: BoxDecoration(
          color: context.theme.surfaceLayers.layer3,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: EdgeInsets.all(4),
        margin: EdgeInsets.only(bottom: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null)
              Container(
                margin: EdgeInsets.only(bottom: 4),
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: context.theme.surfaceLayers.layer1,
                ),
                child: DefaultTextStyle(
                  child: title,
                  style: context.textTheme.highlight,
                ),
              ),
            if (content != null) content,
          ],
        ),
      ));
}
