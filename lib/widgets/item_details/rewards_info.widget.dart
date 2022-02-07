// @dart=2.9

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_item_quantity.dart';

import 'package:flutter/material.dart';
import 'package:little_light/pages/item_details/item_details.page.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateless_item.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

import 'package:little_light/widgets/item_list/items/weapon/weapon_inventory_item.widget.dart';

class RewardsInfoWidget extends BaseDestinyStatelessItemWidget {
  RewardsInfoWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key,
      String characterId})
      : super(
            item: item,
            definition: definition,
            instanceInfo: instanceInfo,
            key: key,
            characterId: characterId);

  @override
  Widget build(BuildContext context) {
    var items =
        definition.value?.itemValue?.where((i) => i.itemHash != null)?.toList();
    if ((items?.length ?? 0) == 0) return Container();
    return Column(
        children: [buildHeader(context), buildRewardItems(context, items)]);
  }

  Widget buildHeader(BuildContext context) {
    return HeaderWidget(
        alignment: Alignment.centerLeft,
        child: TranslatedTextWidget(
          "Rewards",
          uppercase: true,
          style: TextStyle(fontWeight: FontWeight.bold),
        ));
  }

  Widget buildRewardItems(
      BuildContext context, List<DestinyItemQuantity> items) {
    return Column(
        children: items.map((item) => buildRewardItem(context, item)).toList());
  }

  Widget buildRewardItem(BuildContext context, DestinyItemQuantity rewardItem) {
    return DefinitionProviderWidget<DestinyInventoryItemDefinition>(
        rewardItem.itemHash, (def) {
      if (def.equippable ?? false) {
        return Container(
            margin: EdgeInsets.all(4),
            child: Stack(children: [
              Container(
                  height: 96,
                  child: WeaponInventoryItemWidget(
                    null,
                    def,
                    null,
                    characterId: null,
                    uniqueId: null,
                  )),
              Positioned.fill(
                  child: Material(
                color: Colors.transparent,
                child: InkWell(
                  enableFeedback: false,
                  child: Container(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemDetailsPage(definition: def),
                      ),
                    );
                  },
                ),
              ))
            ]));
      }
      return Container(
          padding: EdgeInsets.all(4),
          child: Row(children: [
            Container(
                child: QueuedNetworkImage(
                  imageUrl: BungieApiService.url(def.displayProperties.icon),
                ),
                width: 24,
                height: 24),
            Container(
              width: 8,
            ),
            Text(def.displayProperties.name),
            (rewardItem.quantity ?? 0) > 1
                ? Text(" x ${rewardItem.quantity}")
                : Container()
          ]));
    });
  }
}
