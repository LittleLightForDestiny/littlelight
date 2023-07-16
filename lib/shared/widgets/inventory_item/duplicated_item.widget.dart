import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/item_notes/item_notes.bloc.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/littlelight/wishlists.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/shared/utils/extensions/ammo_type_data.dart';
import 'package:little_light/shared/utils/extensions/element_type_data.dart';
import 'package:little_light/shared/utils/extensions/inventory_item_data.dart';
import 'package:little_light/shared/widgets/character/postmaster_icon.widget.dart';
import 'package:little_light/shared/widgets/inventory_item/inventory_item_mods.dart';
import 'package:little_light/shared/widgets/inventory_item/utils/get_mods_socket_category.dart';
import 'package:little_light/shared/widgets/inventory_item/utils/get_perks_socket_category.dart';
import 'package:little_light/shared/widgets/tags/tag_icon.widget.dart';
import 'package:little_light/shared/widgets/ui/center_icon_workaround.dart';
import 'package:little_light/shared/widgets/wishlists/wishlist_badges.widget.dart';
import 'package:little_light/utils/stats_total.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:provider/provider.dart';
import 'inventory_item_perks.dart';
import 'inventory_item_stats.dart';
import 'utils/get_energy_capacity.dart';

const _expectedItemSize = Size(172.0, 116.0);
const _padding = 4.0;
const _emblemIconSize = 40.0;
const _tagIconSize = 16.0;
const _primaryStatIconsSize = 18.0;

class DuplicatedItemWidget extends StatelessWidget {
  static const expectedSize = _expectedItemSize;
  final DestinyItemInfo item;

  const DuplicatedItemWidget(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Positioned.fill(
        child: buildEmblemBackground(context),
      ),
      buildContent(context),
    ]);
  }

  Widget buildContent(BuildContext context) {
    final definition = context.definition<DestinyInventoryItemDefinition>(item.itemHash);
    return Container(
        padding: EdgeInsets.all(_padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [buildEmblemIcon(context), buildMainInfo(context)],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildModsAndTags(context),
                if (definition?.isArmor ?? false) buildStats(context, definition),
                if (definition?.isWeapon ?? false) buildWeaponPerks(context, definition),
              ],
            ),
          ],
        ));
  }

  Widget buildMainInfo(BuildContext context) {
    final definition = context.definition<DestinyInventoryItemDefinition>(item.itemHash);
    return Container(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
          Row(
              children: [
            buildWishlistTags(context),
            if (definition?.isArmor ?? false) buildTotalStats(context, definition),
            buildCharacterName(context),
          ].whereType<Widget>().toList()),
          if (definition?.isArmor ?? false) buildArmorMainInfo(context, definition),
          if (definition?.isWeapon ?? false) buildWeaponMainInfo(context, definition),
        ]));
  }

  Widget buildWeaponMods(BuildContext context) {
    final definition = context.definition<DestinyInventoryItemDefinition>(item.itemHash);
    final manifest = context.read<ManifestService>();
    if (definition == null) return Container();
    if (!definition.isWeapon) return Container();
    return FutureBuilder<int?>(
        future: getModsSocketCategory(manifest, definition),
        builder: (context, snapshot) {
          final categoryHash = snapshot.data;
          if (categoryHash == null) return Container();
          return Container(
            margin: EdgeInsets.only(top: 4),
            alignment: Alignment.bottomRight,
            child: InventoryItemMods(
              item,
              categoryHash: categoryHash,
            ),
          );
        });
  }

  Widget buildWeaponPerks(BuildContext context, DestinyInventoryItemDefinition? definition) {
    final manifest = context.read<ManifestService>();
    if (definition == null) return Container();
    return FutureBuilder<int?>(
        future: getPerksSocketCategory(manifest, definition),
        builder: (context, snapshot) {
          final categoryHash = snapshot.data;
          if (categoryHash == null) return Container();
          return Container(
            alignment: Alignment.bottomRight,
            child: InventoryItemPerks(
              item,
              includeUnequipped: true,
              categoryHash: categoryHash,
            ),
          );
        });
  }

  Widget buildWeaponMainInfo(BuildContext context, DestinyInventoryItemDefinition? definition) {
    final damageType = item.damageType;
    final damageColor = damageType?.getColorLayer(context).layer2;
    final powerLevel = item.primaryStatValue;
    final textStyle = context.textTheme.itemPrimaryStatHighDensity;
    final ammoType = definition?.equippingBlock?.ammoType;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Icon(
            ammoType?.icon,
            color: ammoType?.color,
            size: _primaryStatIconsSize,
          ),
        ),
        Icon(
          damageType?.icon,
          size: _primaryStatIconsSize,
          color: damageColor,
        ),
        Text(
          "$powerLevel",
          style: textStyle.copyWith(color: damageColor),
        ),
      ],
    );
  }

  Widget buildArmorMainInfo(BuildContext context, DestinyInventoryItemDefinition? definition) {
    final powerLevel = item.primaryStatValue;
    final textStyle = context.textTheme.itemPrimaryStatHighDensity;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildEnergyCapacity(context, definition),
        const SizedBox(width: 4),
        Text(
          "$powerLevel",
          style: textStyle,
        ),
      ].whereType<Widget>().toList(),
    );
  }

  Widget? buildTotalStats(BuildContext context, DestinyInventoryItemDefinition? definition) {
    final total = item.stats?.values.fold<int>(0, (t, stat) => t + (stat.value ?? 0));
    if (total == null) return null;
    final color = getStatsTotalColor(total, context);
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      decoration: BoxDecoration(
        color: context.theme.surfaceLayers.layer0,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        "T{statsTotal}".translate(context, replace: {"statsTotal": "$total"}),
        style: context.textTheme.subtitle.copyWith(
          color: color,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget buildStats(BuildContext context, DestinyInventoryItemDefinition? definition) {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: InventoryItemStats(
          item,
        ));
  }

  Widget buildEnergyCapacity(BuildContext context, DestinyInventoryItemDefinition? definition) {
    final manifest = context.read<ManifestService>();
    if (definition == null) return Container();
    return FutureBuilder<DestinyEnergyCapacityEntry?>(
        future: getEnergyCapacity(manifest, item, definition),
        builder: (context, snapshot) {
          final capacity = snapshot.data;
          if (capacity == null) return Container();
          final energyLevel = capacity.capacityValue ?? 0;
          final textStyle = context.textTheme.itemPrimaryStatHighDensity;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(width: 20, child: Image.asset('assets/imgs/energy-type-icon.png')),
              Text(
                "$energyLevel",
                style: textStyle,
              ),
            ],
          );
        });
  }

  Widget buildCharacterName(BuildContext context) {
    final profile = context.watch<ProfileBloc>();
    final character = profile.getCharacterById(item.characterId);
    if (character != null) {
      final characterName = ManifestText<DestinyClassDefinition>(
        character.character.classHash,
        uppercase: true,
        style: context.textTheme.highlight,
        textExtractor: (def) => def.genderedClassNamesByGenderHash?["${character.character.genderHash}"],
      );

      return Row(children: [
        characterName,
        if (item.bucketHash == InventoryBucket.lostItems)
          Container(
            height: _tagIconSize,
            width: _tagIconSize,
            child: PostmasterIconWidget(),
            margin: EdgeInsets.only(left: 2),
          )
      ]);
    }

    if (item.bucketHash == InventoryBucket.general) {
      return Text(
        "Vault".translate(context).toUpperCase(),
        style: context.textTheme.highlight,
      );
    }
    return Text(
      "Inventory".translate(context).toUpperCase(),
      style: context.textTheme.highlight,
    );
  }

  Widget buildEmblemBackground(BuildContext context) {
    final character = context.watch<ProfileBloc>().getCharacterById(item.characterId);
    if (character != null) {
      return ManifestImageWidget<DestinyInventoryItemDefinition>(
        character.character.emblemHash,
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
    final character = context.watch<ProfileBloc>().getCharacterById(item.characterId);
    if (character != null) {
      return Container(
        child: ManifestImageWidget<DestinyInventoryItemDefinition>(
          character.character.emblemHash,
          fit: BoxFit.cover,
          urlExtractor: (def) => def.secondaryOverlay,
        ),
        width: _emblemIconSize,
        height: _emblemIconSize,
      );
    }
    if (item.bucketHash == InventoryBucket.general) {
      return Container(
        child: Image.asset(
          "assets/imgs/vault-secondary-overlay.png",
          fit: BoxFit.cover,
        ),
        width: _emblemIconSize,
        height: _emblemIconSize,
      );
    }
    return Container();
  }

  Widget buildModsAndTags(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildItemTags(context),
          buildWeaponMods(context),
        ],
      );

  Widget buildItemTags(BuildContext context) {
    final notes = context.watch<ItemNotesBloc>();
    final tags = notes.tagsFor(item.itemHash, item.instanceId);
    if (tags == null || tags.isEmpty) return Container();
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: tags
            .map((e) => TagIconWidget.fromTag(
                  e,
                  size: _tagIconSize,
                ))
            .toList());
  }

  Widget buildWishlistTags(BuildContext context) {
    final wishlists = context.watch<WishlistsService>();
    final reusable = item.reusablePlugs;
    final wishlistTags = wishlists.getWishlistBuildTags(itemHash: item.itemHash, reusablePlugs: reusable);
    final locked = item.state?.contains(ItemState.Locked) ?? false;
    if (locked == false && wishlistTags.isEmpty) return Container();
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          margin: EdgeInsets.only(right: 4),
          width: _tagIconSize,
          height: _tagIconSize,
          child: CenterIconWorkaround(
            FontAwesomeIcons.lock,
            size: _tagIconSize * .7,
          )),
      if (wishlistTags.isNotEmpty)
        Container(
          margin: EdgeInsets.only(right: 4),
          child: WishlistBadgesWidget(wishlistTags, size: _tagIconSize),
        ),
    ]);
  }
}
