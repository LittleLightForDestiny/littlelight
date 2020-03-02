import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/expiry_date.widget.dart';
import 'package:little_light/widgets/common/small_objective.widget.dart';
import 'package:little_light/widgets/progress_tabs/pursuit_item.widget.dart';

class BountyItemWidget extends PursuitItemWidget {
  BountyItemWidget({Key key, String characterId, DestinyItemComponent item, bool includeCharacterIcon:false})
      : super(
            key: key,
            characterId: characterId,
            item: item,
            includeCharacterIcon: includeCharacterIcon);

  BountyItemWidgetState createState() => BountyItemWidgetState();
}

class BountyItemWidgetState<T extends BountyItemWidget>
    extends PursuitItemWidgetState<T> {
  Widget buildObjectives(
      BuildContext context, DestinyInventoryItemDefinition questStepDef) {
    if (itemObjectives == null) return Container();
    return Container(
      padding: EdgeInsets.all(4).copyWith(top: 0),
      child: Row(
        children: itemObjectives
            .map((objective) =>
                Expanded(child: Container(margin:EdgeInsets.all(2), child:buildObjective(context, objective))))
            .toList(),
      ),
    );
  }

  @override
  Widget buildMainInfo(BuildContext context, BoxConstraints constraints) {
    return Expanded(
        flex: constraints.hasBoundedHeight ? 1 : 0,
        child: Stack(children: <Widget>[
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 64, right: 4),
                color: DestinyData.getTierColor(definition.inventory.tierType),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Container(
                            padding: EdgeInsets.all(4),
                            child: Text(
                              definition.displayProperties.name.toUpperCase(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                              softWrap: false,
                              overflow: TextOverflow.fade,
                            ))),
                    buildCharacterIcon(context),
                  ],
                )),
            Container(
              constraints: BoxConstraints(minHeight: 36),
              padding: EdgeInsets.all(4).copyWith(left: 72),
              child: item?.expirationDate != null && !isComplete
                  ? ExpiryDateWidget(item.expirationDate)
                  : Container(),
            ),
            Expanded(
                flex: constraints.hasBoundedHeight ? 1 : 0,
                child: Container(
                    padding: EdgeInsets.all(4),
                    child: buildDescription(context))),
          ]),
          Positioned(
              top: 4,
              left: 4,
              width: 56,
              height: 56,
              child: buildIcon(context)),
        ]));
  }

  Widget buildObjective(
      BuildContext context, DestinyObjectiveProgress objective) {
    if (objectiveDefinitions == null) return Container();
    var definition = objectiveDefinitions[objective.objectiveHash];
    return SmallObjectiveWidget(
      definition: definition,
      objective: objective,
    );
  }
}
