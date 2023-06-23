import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/models/item_info/definition_item_info.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/widgets/containers/persistent_collapsible_container.dart';
import 'package:little_light/shared/widgets/inventory_item/high_density_inventory_item.dart';
import 'package:little_light/shared/widgets/inventory_item/inventory_item.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

class DetailsItemRewardsWidget extends StatelessWidget {
  final DestinyItemInfo item;
  final DestinyCharacterInfo? character;

  DetailsItemRewardsWidget(
    this.item, {
    this.character,
  }) : super();

  @override
  Widget build(BuildContext context) {
    final definition = context.definition<DestinyInventoryItemDefinition>(item.itemHash);
    final items = definition?.value?.itemValue?.where((i) => shouldShowReward(context, i)).toList();
    if (items == null || items.isEmpty) return Container();
    return Container(
        padding: EdgeInsets.all(4),
        child: PersistentCollapsibleContainer(
          title: Text("Rewards".translate(context).toUpperCase()),
          persistenceID: 'item rewards',
          content: buildContent(context, items),
        ));
  }

  Widget buildContent(BuildContext context, List<DestinyItemQuantity> items) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: items
            .map(
              (item) => buildRewardItem(context, item),
            )
            .toList());
  }

  Widget buildRewardItem(BuildContext context, DestinyItemQuantity rewardItem) {
    final def = context.definition<DestinyInventoryItemDefinition>(rewardItem.itemHash);
    if (def == null) return Container();

    final shouldShow = shouldShowReward(context, rewardItem);
    if (!shouldShow) return Container();

    final item = DefinitionItemInfo.fromDefinition(def);
    if (def.equippable ?? false) {
      return Container(
          margin: EdgeInsets.only(bottom: 2),
          child: Stack(children: [
            SizedBox(
              height: InventoryItemWidgetDensity.High.itemHeight,
              child: HighDensityInventoryItem(item),
            ),
            Positioned.fill(
                child: Material(
              color: Colors.transparent,
              child: InkWell(
                enableFeedback: false,
                onTap: () {},
              ),
            ))
          ]));
    }
    final quantity = rewardItem.quantity ?? 0;
    return Container(
        padding: const EdgeInsets.only(bottom: 2),
        child: Row(children: [
          SizedBox(
            width: 24,
            height: 24,
            child: ManifestImageWidget<DestinyInventoryItemDefinition>(item.itemHash),
          ),
          Container(
            width: 8,
          ),
          Expanded(
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    ManifestText<DestinyInventoryItemDefinition>(item.itemHash),
                    if (quantity > 1) Text(" x $quantity"),
                  ])))
        ]));
  }

  bool shouldShowReward(BuildContext context, DestinyItemQuantity rewardItem) {
    final isConditional = rewardItem.hasConditionalVisibility ?? false;
    if (!isConditional) return true;
    final rewardDef = context.definition<DestinyInventoryItemDefinition>(rewardItem.itemHash);
    if (rewardDef == null) return false;
    final itemClass = rewardDef.classType;
    if (itemClass == null || itemClass == DestinyClass.Unknown) return true;
    final characterClass = character?.character.classType;
    if (characterClass == null || characterClass == DestinyClass.Unknown) return true;
    return characterClass == itemClass;
  }
}
