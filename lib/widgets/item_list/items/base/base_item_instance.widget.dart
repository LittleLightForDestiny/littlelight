// @dart=2.9

import 'package:bungie_api/enums/destiny_item_type.dart';
import 'package:bungie_api/enums/item_state.dart';
import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_class_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_vendor_definition.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/littlelight/item_notes.consumer.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:little_light/utils/socket_category_hashes.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/primary_stat.widget.dart';
import 'package:little_light/widgets/common/wishlist_badges.widget.dart';
import 'package:little_light/widgets/item_list/items/base/base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/base/item_armor_stats.widget.dart';
import 'package:little_light/widgets/item_list/items/base/item_mods.widget.dart';
import 'package:little_light/widgets/item_list/items/base/item_perks.widget.dart';
import 'package:little_light/widgets/item_tags/item_tag.widget.dart';

typedef OnItemHandler = void Function(
    DestinyItemComponent item,
    DestinyInventoryItemDefinition itemDefinition,
    DestinyItemInstanceComponent instanceInfo,
    String characterId);

class BaseItemInstanceWidget extends BaseInventoryItemWidget
    with WishlistsConsumer, ProfileConsumer, ItemNotesConsumer {
  BaseItemInstanceWidget(
    DestinyItemComponent item,
    DestinyInventoryItemDefinition itemDefinition,
    DestinyItemInstanceComponent instanceInfo, {
    Key key,
    @required String uniqueId,
    @required String characterId,
  }) : super(item, itemDefinition, instanceInfo,
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
      Positioned(
        left: 4,
        bottom: 4,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          buildTags(context),
          Container(height: 4),
          modsWidget(context)
        ]),
      ),
      Positioned.fill(
          child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            buildCharacterName(context),
            primaryStatWidget(context),
            definition?.itemType != DestinyItemType.Armor
                ? Expanded(
                    child: Container(),
                  )
                : statsWidget(context),
            definition?.itemType == DestinyItemType.Armor
                ? Expanded(
                    child: Container(),
                  )
                : perksWidget(context),
          ],
        ),
      )),
    ]);
  }

  Widget buildTags(BuildContext context) {
    final reusable = profile.getItemReusablePlugs(item?.itemInstanceId);
    final wishlistTags = wishlistsService.getWishlistBuildTags(
        itemHash: item?.itemHash, reusablePlugs: reusable);
    List<Widget> upper = [];
    var notes = itemNotes.getNotesForItem(item?.itemHash, item?.itemInstanceId);
    var tags = itemNotes.tagsByIds(notes?.tags);
    var locked = item?.state?.contains(ItemState.Locked) ?? false;
    if (tags != null) {
      upper.addAll(tags.map((t) => ItemTagWidget(
            t,
            fontSize: tagIconSize - padding / 2,
            padding: padding / 8,
          )));
    }
    if (locked) {
      upper.add(SizedBox(
          height: tagIconSize,
          width: tagIconSize,
          child: Icon(FontAwesomeIcons.lock, size: titleFontSize * .9)));
    }
    List<Widget> rows = [];
    if (upper.isNotEmpty) {
      upper = upper
          .expand((i) => [
                i,
                Container(
                  width: padding / 2,
                )
              ])
          .toList();
      upper.removeLast();
      rows.add(Row(children: upper));
    }
    if (wishlistTags != null) {
      rows.add(WishlistBadgesWidget(tags: wishlistTags, size: tagIconSize));
    }

    if (rows.isEmpty) return Container();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
    // return WishlistBadgeWidget(tags: wishlistTags, size: tagIconSize);
  }

  Widget buildCharacterName(BuildContext context) {
    if (character != null) {
      return ManifestText<DestinyClassDefinition>(
        character.classHash,
        uppercase: true,
        style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 12),
        textExtractor: (def) =>
            def.genderedClassNamesByGenderHash["${character.genderHash}"],
      );
    }
    if (item.bucketHash == InventoryBucket.general) {
      return ManifestText<DestinyVendorDefinition>(
        1037843411,
        uppercase: true,
        style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 12),
        textExtractor: (def) => def.displayProperties.name,
      );
    }
    return Text("Inventory".translate(context).toUpperCase(),
        style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 12));
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
    return PrimaryStatWidget(
        item: item, definition: definition, instanceInfo: instanceInfo);
  }

  @override
  Widget modsWidget(BuildContext context) {
    if (item?.itemInstanceId == null) return Container();
    return ItemModsWidget(
      definition: definition,
      itemSockets: profile.getItemSockets(item?.itemInstanceId),
      iconSize: 22,
    );
  }

  @override
  Widget perksWidget(BuildContext context) {
    var socketCategoryHash = definition.sockets?.socketCategories
        ?.map((sc) => sc.socketCategoryHash)
        ?.firstWhere((h) => SocketCategoryHashes.perks.contains(h),
            orElse: () => null);
    return ItemPerksWidget(
      socketCategoryHash: socketCategoryHash,
      item: item,
      definition: definition,
      iconSize: 20,
      showUnusedPerks: true,
    );
  }

  Widget statsWidget(BuildContext context) {
    return Container(
        alignment: Alignment.topRight, child: ItemArmorStatsWidget(item: item));
  }
}
