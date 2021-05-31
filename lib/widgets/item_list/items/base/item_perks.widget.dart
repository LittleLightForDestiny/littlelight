import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_socket_entry_definition.dart';
import 'package:bungie_api/models/destiny_item_socket_state.dart';
import 'package:bungie_api/models/destiny_socket_category_definition.dart';
import 'package:bungie_api/models/destiny_item_plug_base.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/wish_list.dart';
import 'package:little_light/services/littlelight/wishlists.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/wishlists_data.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

class ItemPerksWidget extends StatefulWidget {
  final ManifestService manifest = ManifestService();
  final DestinyInventoryItemDefinition definition;
  final double iconSize;
  final DestinyItemComponent item;
  final bool showUnusedPerks;
  final socketCategoryHash;
  final List<DestinyItemSocketState> itemSockets;
  final Map<String, List<DestinyItemPlugBase>> reusablePlugs;
  ItemPerksWidget(
      {Key key,
      this.iconSize = 16,
      this.socketCategoryHash,
      this.showUnusedPerks = false,
      this.definition,
      this.itemSockets,
      this.reusablePlugs,
      this.item})
      : super(key: key);

  @override
  ItemPerksWidgetState createState() {
    return ItemPerksWidgetState();
  }
}

class ItemPerksWidgetState extends State<ItemPerksWidget> {
  List<DestinyItemSocketState> _itemSockets;
  Map<String, List<DestinyItemPlugBase>> _reusablePlugs;
  List<DestinyItemSocketState> get itemSockets =>
      _itemSockets ?? widget.itemSockets;
  DestinyInventoryItemDefinition get definition => widget.definition;
  DestinySocketCategoryDefinition perksCatDefinition;

  @override
  void initState() {
    super.initState();
    _itemSockets =
        ProfileService().getItemSockets(widget?.item?.itemInstanceId);
    if (widget.showUnusedPerks) {
      _reusablePlugs = widget.reusablePlugs ??
          ProfileService().getItemReusablePlugs(widget?.item?.itemInstanceId);
    }
    loadPerks();
  }

  loadPerks() async {
    if (definition?.sockets?.socketCategories == null) {
      return;
    }
    perksCatDefinition = await widget.manifest
        .getDefinition<DestinySocketCategoryDefinition>(
            widget.socketCategoryHash);
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (perksCatDefinition == null) {
      return Container();
    }
    return buildPerks(context, perksCatDefinition);
  }

  Widget buildPerks(BuildContext context, DestinySocketCategoryDefinition def) {
    var socketCategory = definition.sockets.socketCategories.firstWhere(
        (s) => s.socketCategoryHash == def.hash,
        orElse: () => null);
    List<Widget> columns = [];
    if (socketCategory == null) return Container();
    socketCategory.socketIndexes.forEach((index) {
      columns.add(buildPerkColumn(context, index));
    });
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: columns.toList());
  }

  Widget buildPerkColumn(BuildContext context, int index) {
    if (!widget.showUnusedPerks || itemSockets == null) {
      var hash = itemSockets != null
          ? getEquippedPlugHashBySocketIndex(index)
          : getDefaultPerkBySocketIndex(index);
      return buildPerkIcon(context, hash);
    }

    List<int> hashes = getInstancePlugHashesBySocketIndex(index);
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: hashes.map((h) => buildPerkIcon(context, h)).toList(),
    ));
  }

  Widget buildPerkIcon(BuildContext context, int plugHash) {
    if (plugHash == null) {
      return Container();
    }
    var tags = WishlistsService().getPerkTags(widget.definition.hash, plugHash);
    return Container(
      margin: EdgeInsets.only(top: 1, left: 1),
      width: widget.iconSize,
      height: widget.iconSize,
      child: Stack(children: [
        buildTagBorder(tags),
        buildTagBackground(tags),
        ManifestImageWidget<DestinyInventoryItemDefinition>(
          plugHash,
          placeholder: Container(),
        )
      ]),
    );
  }

  buildTagBorder(Set<WishlistTag> tags) {
    List<Color> colors = [];
    if (tags.contains(WishlistTag.GodPVE)) {
      colors.add(Colors.amber);
    } else if (tags.contains(WishlistTag.PVE)) {
      colors.add(Color.lerp(
          WishlistsData.getBgColor(WishlistTag.PVE), Colors.white, .2));
    }
    if (tags.contains(WishlistTag.GodPVP)) {
      colors.add(Colors.amber);
    } else if (tags.contains(WishlistTag.PVP)) {
      colors.add(Color.lerp(
          WishlistsData.getBgColor(WishlistTag.PVP), Colors.white, .2));
    }
    if (colors.length > 0) {
      return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(
                colors: colors,
                stops: colors.map((c) => 0.5).toList(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )));
    }
    return Container();
  }

  buildTagBackground(Set<WishlistTag> tags) {
    List<Color> colors = [];
    if (tags.contains(WishlistTag.PVE) || tags.contains(WishlistTag.GodPVE)) {
      colors.add(WishlistsData.getBgColor(WishlistTag.PVE));
    }
    if (tags.contains(WishlistTag.PVP) || tags.contains(WishlistTag.GodPVP)) {
      colors.add(WishlistsData.getBgColor(WishlistTag.PVP));
    }
    if (colors.length > 0) {
      return Container(
          margin: EdgeInsets.all(1),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(
                colors: colors,
                stops: colors.map((c) => 0.5).toList(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )));
    }
    return Container();
  }

  DestinyItemSocketState getSocketState(int index) {
    if (itemSockets == null) return null;
    return itemSockets[index];
  }

  int getEquippedPlugHashBySocketIndex(int index) {
    var entry = socketEntries[index];
    var state = getSocketState(index);
    if (!(state.isVisible ?? false)) {
      return null;
    }
    if ((state?.plugHash ?? 0) != 0) {
      return state?.plugHash;
    }
    if ((entry.singleInitialItemHash ?? 0) != 0) {
      return entry.singleInitialItemHash;
    }
    return null;
  }

  List<int> getInstancePlugHashesBySocketIndex(int index) {
    var entry = socketEntries[index];
    var state = getSocketState(index);
    var reusable = (_reusablePlugs ?? const {})["$index"];
    if (!(state.isVisible ?? false)) {
      return [];
    }
    if ((reusable?.length ?? 0) > 0) {
      return reusable.map((r) => r.plugItemHash).toList();
    }
    if ((state?.plugHash ?? 0) != 0) {
      return [state?.plugHash];
    }
    if ((entry.singleInitialItemHash ?? 0) != 0) {
      return [entry.singleInitialItemHash];
    }
    return null;
  }

  int getDefaultPerkBySocketIndex(int index) {
    var entry = socketEntries[index];
    if ((entry.singleInitialItemHash ?? 0) != 0) {
      return entry.singleInitialItemHash;
    }
    if ((entry.reusablePlugItems?.length ?? 0) != 0) {
      return entry.reusablePlugItems[0].plugItemHash;
    }
    return null;
  }

  List<DestinyItemSocketEntryDefinition> get socketEntries {
    return definition.sockets.socketEntries;
  }
}
