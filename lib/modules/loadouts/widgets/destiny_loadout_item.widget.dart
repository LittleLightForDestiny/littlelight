import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/destiny_loadout.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/extensions/inventory_item_data.dart';
import 'package:little_light/shared/widgets/inventory_item/low_density_inventory_item.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

class DestinyLoadoutItemWidget extends StatelessWidget {
  final DestinyLoadoutItemInfo item;
  const DestinyLoadoutItemWidget(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(8),
        child: Row(children: [
          buildItemIcon(context),
          Container(width: 8),
          Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: buildItemMods(context))),
        ]));
  }

  Widget buildItemIcon(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      child: LowDensityInventoryItem(item),
    );
  }

  Widget buildItemMods(BuildContext context) {
    final def = context.definition<DestinyInventoryItemDefinition>(item.itemHash);
    if (def?.isWeapon ?? false) {
      return buildModIcons(context, ["shader", "trackers", "skins", "mod"]);
    }
    if (def?.isArmor ?? false) {
      return buildModIcons(context, ["shader", "intrinsics", "skins"]);
    }
    if (def?.isSubclass ?? false) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        buildModIcons(context, ["supers", "fragments", "trinkets"]),
        buildModIcons(context, ["movement", "class_abilities", "supers", "aspects", "melee", "grenade", "totems"])
      ]);
    }
    return Container();
  }

  Widget buildModIcons(BuildContext context, List<String> categoryIdentifiersDenylist) {
    final def = context.definition<DestinyInventoryItemDefinition>(item.itemHash);
    final socketCategories = def?.sockets?.socketCategories;
    if (socketCategories == null) return Container();
    List<int> plugHashes = <int>[];
    for (final cat in socketCategories) {
      final catDef = context.definition<DestinySocketCategoryDefinition>(cat.socketCategoryHash);
      if (catDef == null) continue;
      final indexes = cat.socketIndexes ?? [];
      final categoryPlugHashes = indexes.map((i) => item.sockets?[i].plugHash).nonNulls;
      plugHashes = [...plugHashes, ...categoryPlugHashes];
    }
    return Row(
      children: plugHashes.map(
        (p) {
          final plugDef = context.definition<DestinyInventoryItemDefinition>(p);
          final plugCategoryId = plugDef?.plug?.plugCategoryIdentifier;
          if (plugCategoryId == null) return Container();
          if (categoryIdentifiersDenylist.any((pattern) => plugCategoryId.contains(pattern))) return Container();
          return Container(
              margin: EdgeInsets.all(2),
              width: 40,
              height: 40,
              child: ManifestImageWidget<DestinyInventoryItemDefinition>(p));
        },
      ).toList(),
    );
  }
}
