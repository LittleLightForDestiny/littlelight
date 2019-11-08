import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_class_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_vendor_definition.dart';
import 'package:flutter/material.dart';

import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/primary_stat.widget.dart';

import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/item_list/items/base/base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/base/item_mods.widget.dart';
import 'package:little_light/widgets/item_list/items/base/item_perks.widget.dart';

typedef void OnItemHandler(
    DestinyItemComponent item,
    DestinyInventoryItemDefinition itemDefinition,
    DestinyItemInstanceComponent instanceInfo,
    String characterId);

class BaseItemInstanceWidget extends BaseInventoryItemWidget {
  BaseItemInstanceWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition itemDefinition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key,
      @required String uniqueId,
      @required String characterId,
      })
      : super(item, itemDefinition, instanceInfo,
            key: key, characterId: characterId, uniqueId: uniqueId);

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Positioned.fill(
        child: buildEmblemBackground(context),
      ),
      Positioned(
        left: 4,
        top: 4,
        width: 48,
        height: 48,
        child: buildEmblemIcon(context),
      ),
      Positioned.fill(
          child: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            buildCharacterName(context),
            primaryStatWidget(context),
            perksWidget(context),
            modsWidget(context)
          ],
        ),
      )),
    ]);
  }

  Widget buildCharacterName(BuildContext context) {
    if (character != null) {
      return ManifestText<DestinyClassDefinition>(
        character.classHash,
        uppercase: true,
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        textExtractor: (def) =>
            def.genderedClassNamesByGenderHash["${character.genderHash}"],
      );
    }
    if (item.bucketHash == InventoryBucket.general) {
      return ManifestText<DestinyVendorDefinition>(
        1037843411,
        uppercase: true,
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        textExtractor: (def) => def.displayProperties.name,
      );
    }
    return TranslatedTextWidget("Inventory",
        uppercase: true,
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12));
  }

  Widget buildEmblemBackground(BuildContext context) {
    if (character != null) {
      return ManifestImageWidget<DestinyInventoryItemDefinition>(
        character.emblemHash,
        fit: BoxFit.cover,
        urlExtractor: (def) => def.secondarySpecial,
      );
    }
    if (item.bucketHash == InventoryBucket.general) {
      return Image.asset(
        "assets/imgs/vault-secondary-special.jpg",
        fit: BoxFit.cover,
      );
    }
    return Container();
  }

  Widget buildEmblemIcon(BuildContext context) {
    if (character != null) {
      return ManifestImageWidget<DestinyInventoryItemDefinition>(
        character.emblemHash,
        fit: BoxFit.cover,
        urlExtractor: (def) => def.secondaryOverlay,
      );
    }
    if (item.bucketHash == InventoryBucket.general) {
      return Image.asset(
        "assets/imgs/vault-secondary-overlay.png",
        fit: BoxFit.cover,
      );
    }
    return Container();
  }

  DestinyCharacterComponent get character => profile.getCharacter(characterId);

  @override
  Widget primaryStatWidget(BuildContext context) {
    return PrimaryStatWidget(definition:definition, instanceInfo:instanceInfo);
  }

  @override
  Widget modsWidget(BuildContext context) {
    if(item?.itemInstanceId == null) return Container();
    return ItemModsWidget(
      definition: definition,
      itemSockets: profile.getItemSockets(item?.itemInstanceId),
      iconSize: 22,
    );
  }

  @override
  Widget perksWidget(BuildContext context) {
    var sockets = item?.itemInstanceId == null ? null : profile.getItemSockets(item?.itemInstanceId);
    var socketCategoryHash = definition.sockets?.socketCategories?.map((sc)=>sc.socketCategoryHash)?.firstWhere((h)=>DestinyData.socketCategoryPerkHashes.contains(h), orElse: ()=>null);
    return ItemPerksWidget(
      socketCategoryHash: socketCategoryHash,
      itemSockets: sockets,
      definition: definition,
      iconSize: 20,
    );
  }
}
