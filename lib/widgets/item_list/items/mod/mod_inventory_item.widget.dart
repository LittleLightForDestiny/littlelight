import 'package:bungie_api/enums/destiny_energy_type.dart';
import 'package:bungie_api/enums/destiny_stat_category.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/item_list/items/base/base_inventory_item.widget.dart';

class ModInventoryItemWidget extends BaseInventoryItemWidget {
  ModInventoryItemWidget(
    DestinyItemComponent item,
    DestinyInventoryItemDefinition definition,
    DestinyItemInstanceComponent instanceInfo, {
    @required String characterId,
    Key key,
    @required String uniqueId,
  }) : super(
          item,
          definition,
          instanceInfo,
          characterId: characterId,
          uniqueId: uniqueId,
        );

  @override
  itemIcon(BuildContext context) {
    var energyType =
        definition?.plug?.energyCost?.energyType ?? DestinyEnergyType.Any;
    var energyCost = definition?.plug?.energyCost?.energyCost ?? 0;
    return Container(
        child: AspectRatio(
      aspectRatio: 1,
      child: Stack(children: [
        Positioned.fill(child: super.itemIcon(context)),
        energyType == DestinyEnergyType.Any
            ? Container()
            : Positioned.fill(
                child: ManifestImageWidget<DestinyStatDefinition>(
                    DestinyData.getEnergyTypeCostHash(energyType))),
        energyCost == 0
            ? Container()
            : Positioned(
                top: 8,
                right: 10,
                child: Text(
                  "$energyCost",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                )),
      ]),
    ));
  }

  @override
  Widget modsWidget(BuildContext context) {
    var energyType =
        definition?.plug?.energyCost?.energyType ?? DestinyEnergyType.Any;
    var energyCost = definition?.plug?.energyCost?.energyCost ?? 0;
    var color = DestinyData.getEnergyTypeLightColor(energyType);
    if (energyCost == 0) return Container();
    return Positioned(
        bottom: 4,
        right: 8,
        child: 
          Row(
            children: <Widget>[
              energyType != DestinyEnergyType.Any
                  ? Icon(DestinyData.getEnergyTypeIcon(energyType),
                      size: 22, color: color)
                  : Container(),
              Container(
                width: energyType != DestinyEnergyType.Any ? 4 : 0,
              ),
              Text(
                "$energyCost",
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 22, color: color),
              )
            ],
          )
        );
  }

  @override
  Widget perksWidget(BuildContext context) {
    return Positioned(
        bottom: 8,
        left: 96,
        height: 18,
        child: Row(
          children: definition?.investmentStats
                  ?.map((s) => DefinitionProviderWidget<DestinyStatDefinition>(
                          s.statTypeHash, (def) {
                        if (def?.statCategory != DestinyStatCategory.Defense)
                          return Container();
                        return Row(
                          children: <Widget>[
                            ManifestImageWidget<DestinyStatDefinition>(
                                s.statTypeHash),
                            Text("${s.value}",
                                style: TextStyle(
                                    color:s.value > 0 ? Colors.grey.shade300 : DestinyData.negativeFeedback,
                                    fontWeight: FontWeight.w500, fontSize: 16)),
                            Container(
                              width: 8,
                            )
                          ],
                        );
                      }))
                  ?.toList() ??
              [],
        ));
  }
}
