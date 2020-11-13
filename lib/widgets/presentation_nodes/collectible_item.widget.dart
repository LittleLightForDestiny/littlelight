import 'dart:async';

import 'package:bungie_api/enums/destiny_item_type.dart';
import 'package:bungie_api/models/destiny_collectible_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/screens/item_detail.screen.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/services/selection/selection.service.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

import 'package:little_light/widgets/item_list/items/armor/armor_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/base/base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/emblem/emblem_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/mod/mod_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/weapon/weapon_inventory_item.widget.dart';

class CollectibleItemWidget extends StatefulWidget {
  final ManifestService manifest = new ManifestService();
  final ProfileService profile = new ProfileService();
  final AuthService auth = new AuthService();
  final Map<int, List<ItemWithOwner>> itemsByHash;
  final int hash;
  CollectibleItemWidget({Key key, this.hash, this.itemsByHash})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CollectibleItemWidgetState();
  }
}

class CollectibleItemWidgetState extends State<CollectibleItemWidget> {
  DestinyCollectibleDefinition _definition;
  DestinyInventoryItemDefinition _itemDefinition;
  DestinyCollectibleDefinition get definition {
    return widget.manifest.getDefinitionFromCache<DestinyCollectibleDefinition>(
            widget.hash) ??
        _definition;
  }

  List<ItemWithOwner> get items {
    if (definition?.itemHash != null &&
        widget.itemsByHash != null &&
        widget.itemsByHash.containsKey(definition.itemHash)) {
      return widget.itemsByHash[definition.itemHash];
    }
    return null;
  }

  bool get selected => items != null
      ? items.every((i) {
          return SelectionService().isSelected(i);
        })
      : false;

  @override
  void initState() {
    super.initState();
    loadDefinition();
    StreamSubscription<List<ItemWithOwner>> sub;
    sub = SelectionService().broadcaster.listen((selectedItems) {
      if (!mounted) {
        sub.cancel();
        return;
      }
      setState(() {});
    });
  }

  loadDefinition() async {
    if (definition == null) {
      _definition = await widget.manifest
          .getDefinition<DestinyCollectibleDefinition>(widget.hash);
      if (mounted) {
        setState(() {});
      }
    }
    _itemDefinition = await widget.manifest
        .getDefinition<DestinyInventoryItemDefinition>(definition.itemHash);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
        opacity: unlocked ? 1 : .4,
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade600, width: 1),
                gradient: LinearGradient(
                    begin: Alignment(0, 0),
                    end: Alignment(1, 2),
                    colors: [
                      Colors.white.withOpacity(.05),
                      Colors.white.withOpacity(.1),
                      Colors.white.withOpacity(.03),
                      Colors.white.withOpacity(.1)
                    ])),
            child: Stack(children: [
              buildItem(context),
              Positioned(right: 4, bottom: 4, child: buildItemCount()),
              Positioned.fill(
                child: buildSelectedBorder(context),
              ),
              buildButton(context),
            ])));
  }

  Widget buildItem(BuildContext context) {
    if (_itemDefinition == null) {
      if (definition?.redacted ?? false)
        return Container(
            alignment: Alignment.center,
            child: Text(definition.displayProperties.name));
      return Container();
    }
    if (_itemDefinition.itemType == DestinyItemType.Armor) {
      return ArmorInventoryItemWidget(
        null,
        _itemDefinition,
        null,
        characterId: null,
        uniqueId: null,
      );
    }
    if (_itemDefinition.itemType == DestinyItemType.Weapon) {
      return WeaponInventoryItemWidget(
        null,
        _itemDefinition,
        null,
        characterId: null,
        uniqueId: null,
      );
    }

    if (_itemDefinition.itemType == DestinyItemType.Emblem) {
      return EmblemInventoryItemWidget(
        null,
        _itemDefinition,
        null,
        characterId: null,
        uniqueId: null,
      );
    }

    if (_itemDefinition.itemType == DestinyItemType.Mod) {
      return ModInventoryItemWidget(
        null,
        _itemDefinition,
        null,
        characterId: null,
        uniqueId: null,
      );
    }

    return BaseInventoryItemWidget(
      null,
      _itemDefinition,
      null,
      characterId: null,
      uniqueId: null,
    );
  }

  Widget buildIcon(BuildContext context) {
    if (definition?.displayProperties?.icon == null) return Container();
    return QueuedNetworkImage(
      imageUrl: BungieApiService.url(definition.displayProperties.icon),
    );
  }

  buildTitle(BuildContext context, DestinyCollectibleDefinition definition) {
    return Expanded(
        child: Container(padding: EdgeInsets.all(8), child: buildTitleText()));
  }

  Widget buildButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        enableFeedback: false,
        child: Container(),
        onTap: () => onTap(context),
        onLongPress: () => onLongPress(context),
      ),
    );
  }

  void onTap(BuildContext context) async {
    if (definition.itemHash == null) {
      return;
    }
    if (SelectionService().multiselectActivated) {
      onLongPress(context);
      return;
    }

    DestinyInventoryItemDefinition itemDef = await widget.manifest
        .getDefinition<DestinyInventoryItemDefinition>(definition.itemHash);
    if (itemDef == null) {
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailScreen(definition: itemDef),
      ),
    );
  }

  void onLongPress(BuildContext context) {
    if ((items?.length ?? 0) == 0) return;
    if (!selected) {
      SelectionService().activateMultiSelect();
      for (var item in this.items) {
        if (!SelectionService().isSelected(item)) {
          SelectionService().addItem(ItemWithOwner(item.item, item.ownerId));
        }
      }
    } else {
      for (var item in this.items) {
        SelectionService().removeItem(ItemWithOwner(item.item, item.ownerId));
      }
    }

    setState(() {});
  }

  Widget buildSelectedBorder(BuildContext context) {
    if (selected) {
      return Container(
        decoration: BoxDecoration(
            border: Border.all(width: 2, color: Colors.lightBlue.shade400)),
      );
    }
    return Container();
  }

  buildTitleText() {
    if (definition == null) return Container();
    return Text(definition.displayProperties.name,
        softWrap: true,
        style: TextStyle(
            color: Colors.grey.shade300, fontWeight: FontWeight.bold));
  }

  Widget buildItemCount() {
    if ((items?.length ?? 0) == 0) {
      return Container();
    }
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blueGrey.shade300,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
        color: Colors.blueGrey.shade700.withOpacity(.8),
      ),
      alignment: Alignment.center,
      child: Text(
        "${items.length}",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  bool get unlocked {
    if (!widget.auth.isLogged) return true;
    if (definition == null) return false;
    return widget.profile.isCollectibleUnlocked(widget.hash, definition.scope);
  }
}
