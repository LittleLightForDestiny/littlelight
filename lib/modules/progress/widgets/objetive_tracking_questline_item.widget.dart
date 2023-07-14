import 'package:bungie_api/src/models/destiny_inventory_item_definition.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/extensions/tier_type_data.dart';
import 'package:little_light/shared/widgets/inventory_item/high_density_inventory_item.dart';
import 'package:little_light/shared/widgets/objectives/objective.widget.dart';

class ObjectiveTrackingQuestlineItemWidget extends HighDensityInventoryItem {
  ObjectiveTrackingQuestlineItemWidget(DestinyItemInfo item) : super(item);

  @override
  Widget buildWithDefinition(BuildContext context, DestinyInventoryItemDefinition? definition) {
    return Container(
      padding: EdgeInsets.all(1),
      color: definition?.inventory?.tierType?.getColorLayer(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(child: super.buildWithDefinition(context, definition)),
          buildObjectiveProgress(context, definition)
        ],
      ),
    );
  }

  @override
  Widget buildMainContent(BuildContext context, DestinyInventoryItemDefinition? definition) {
    final questlineDef = context.definition<DestinyInventoryItemDefinition>(definition?.objectives?.questlineItemHash);
    final currentStep = questlineDef?.setData?.itemList?.indexWhere((i) => i.itemHash == item.itemHash);
    final totalSteps = questlineDef?.setData?.itemList?.length;
    final itemType = definition?.itemTypeDisplayName;
    if (itemType == null) return Container();
    if (currentStep == null || currentStep < 0) return Container();
    if (totalSteps == null || totalSteps <= 0) return Container();
    return Container(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("{stepType} {currentStep} of {totalSteps}".translate(context, replace: {
              "stepType": itemType,
              "currentStep": "${currentStep + 1}",
              "totalSteps": "$totalSteps",
            })),
            buildStepCompletionBars(context, totalSteps, currentStep),
            Text(
              definition?.displayProperties?.description ?? "",
              style: context.textTheme.body,
            )
          ],
        ));
  }

  Widget buildStepCompletionBars(BuildContext context, int total, int completed) {
    return Row(
      children: List.generate(
          total,
          (index) => Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.symmetric(vertical: 4).copyWith(right: 4),
                  color: index > completed ? context.theme.surfaceLayers.layer3 : context.theme.upgradeLayers.layer1,
                ),
              )),
    );
  }

  @override
  Widget buildObjectiveProgress(BuildContext context, DestinyInventoryItemDefinition? definition) {
    final objectiveHashes = definition?.objectives?.objectiveHashes;
    if (objectiveHashes == null || objectiveHashes.isEmpty) return Container();

    return Container(
        color: context.theme.surfaceLayers.layer1,
        padding: EdgeInsets.all(4),
        child: Column(
          children: objectiveHashes.map((objectiveHash) {
            final objective =
                item.objectives?.objectives?.firstWhereOrNull((objective) => objective.objectiveHash == objectiveHash);
            return ObjectiveWidget(
              objectiveHash,
              objective: objective,
              placeholder: definition?.displayProperties?.description,
            );
          }).toList(),
        ));
  }
}
