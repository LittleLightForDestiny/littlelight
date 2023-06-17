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

class ObjectiveTrackingBountyItemWidget extends HighDensityInventoryItem {
  ObjectiveTrackingBountyItemWidget(DestinyItemInfo item) : super(item);

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
    if (definition == null) return Container();
    return Container(
      padding: const EdgeInsets.only(top: 4, right: 4, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: buildItemTypeName(context, definition)),
              buildExpirationDate(context, definition),
            ],
          )),
          Container(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              definition.displayProperties?.description ?? "",
              style: context.textTheme.body,
            ),
          )
        ],
      ),
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
