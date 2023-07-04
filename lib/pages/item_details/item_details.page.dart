// @dart=2.9

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_stat_group_definition.dart';
import 'package:bungie_api/models/destiny_vendor_sale_item_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/loadouts/loadout_item_index.dart';
import 'package:little_light/core/blocs/loadouts/loadouts.bloc.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/pages/item_details/item_details.page_route.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/helpers/loadout_helpers.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
// import 'package:little_light/widgets/inventory_tabs/inventory_notification.widget.dart';

import 'package:little_light/widgets/item_details/item_detail_loadouts.widget.dart';
import 'package:little_light/widgets/item_details/item_level.widget.dart';
import 'package:little_light/widgets/item_details/item_vendor_info.widget.dart';
import 'package:little_light/widgets/item_sockets/item_socket.controller.dart';
import 'package:provider/provider.dart';

class ItemDetailsPage extends StatefulWidget {
  const ItemDetailsPage({
    Key key,
  });

  @override
  State<ItemDetailsPage> createState() => ItemDetailScreenState();
}

class ItemDetailScreenState extends State<ItemDetailsPage> with AuthConsumer, ManifestConsumer {
  ItemDetailsPageArgumentsBase get routeArgs {
    final args = ModalRoute.of(context).settings.arguments;
    if (args is ItemDetailsPageArgumentsBase) return args;
    return null;
  }

  ItemDetailsPageArguments get itemRouteArgs {
    final args = routeArgs;
    if (args is ItemDetailsPageArguments) return args;
    return null;
  }

  ItemInfoPageArguments get itemInfoRouteArgs {
    final args = routeArgs;
    if (args is ItemInfoPageArguments) return args;
    return null;
  }

  VendorItemDetailsPageArguments get vendorItemRouteArgs {
    final args = routeArgs;
    if (args is VendorItemDetailsPageArguments) return args;
    return null;
  }

  int selectedPerk;
  Map<int, int> selectedPerks = {};
  ItemSocketController socketController;
  DestinyStatGroupDefinition statGroupDefinition;
  List<ItemWithOwner> duplicates;
  List<LoadoutItemIndex> loadouts;
  bool loaded = false;

  int get itemHash => routeArgs.itemHash;
  String get uniqueId => routeArgs.uniqueId;
  bool get hideItemManagement => routeArgs.hideItemManagement;

  DestinyItemInfo get itemWithOwner {
    final args = routeArgs;
    if (args is ItemDetailsPageArguments) {
      return args.item;
    }
    return null;
  }

  DestinyItemInfo get itemInfo {
    return itemInfoRouteArgs.item;
  }

  DestinyVendorSaleItemComponent get vendorItem {
    final args = routeArgs;
    if (args is VendorItemDetailsPageArguments) {
      return args.vendorItem;
    }
    return null;
  }

  DestinyInventoryItemDefinition definition;
  DestinyItemComponent get item => null;
  String get characterId => itemInfo?.characterId;

  DestinyItemInstanceComponent get instanceInfo => null;

  @override
  initState() {
    super.initState();
    asyncInit();
  }

  asyncInit() async {
    await Future.delayed(Duration.zero);
    final route = ModalRoute.of(context);
    await getDefinitionFromCache();
    await loadItemDefinition();
    await Future.delayed(route?.transitionDuration ?? Duration.zero);
    await initSocketController();
    await loadDefinitions();
    if (mounted) {
      setState(() {
        loaded = true;
      });
    }
  }

  Future<void> getDefinitionFromCache() async {
    definition = manifest.getDefinitionFromCache<DestinyInventoryItemDefinition>(itemHash);
    if (definition != null) setState(() {});
  }

  Future<void> loadItemDefinition() async {
    if (definition != null) return;
    definition = await manifest.getDefinition<DestinyInventoryItemDefinition>(itemHash);
  }

  Future<void> initSocketController() async {
    if (routeArgs is VendorItemDetailsPageArguments) {
      final args = routeArgs as VendorItemDetailsPageArguments;
      socketController = ItemSocketController.fromVendorItem(
          characterId: args.characterId, vendorHash: args.vendorHash, vendorItem: vendorItem);
      return;
    }
    socketController = ItemSocketController.fromItemHash(itemHash);
  }

  Future<void> loadDefinitions() async {
    await findLoadouts();
    await findDuplicates();
    await loadStatGroupDefinition();
  }

  findLoadouts() async {
    final allLoadouts = context.read<LoadoutsBloc>().loadouts;
    if (item?.itemInstanceId == null) return;
    loadouts = allLoadouts?.where((l) => l.containsItem(item.itemInstanceId))?.toList() ?? [];
  }

  findDuplicates() async {
    // List<ItemWithOwner> allItems = [];
    // Iterable<String> charIds = profile.characters.map((char) => char.characterId);
    // for (var charId in charIds) {
    //   allItems.addAll(profile
    //       .getCharacterEquipment(charId)
    //       .where((i) => i.itemHash == definition.hash)
    //       .map((item) => ItemWithOwner(item, charId)));
    //   allItems.addAll(profile
    //       .getCharacterInventory(charId)
    //       .where((i) => i.itemHash == definition.hash)
    //       .map((item) => ItemWithOwner(item, charId)));
    // }
    // allItems.addAll(profile
    //     .getProfileInventory()
    //     .where((i) => i.itemHash == definition.hash)
    //     .map((item) => ItemWithOwner(item, null)));
    // duplicates = allItems.where((i) {
    //   return i.item.itemInstanceId != null && i.item.itemInstanceId != item?.itemInstanceId;
    // }).toList();

    // duplicates = await InventoryUtils.sortDestinyItems(duplicates);
  }

  Future loadStatGroupDefinition() async {
    if (definition?.stats?.statGroupHash != null) {
      statGroupDefinition = await manifest.getDefinition<DestinyStatGroupDefinition>(definition?.stats?.statGroupHash);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQueryHelper(context).isPortrait) {
      return buildPortrait(context);
    }
    return buildLandscape(context);
  }

  Widget buildPortrait(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      CustomScrollView(
        slivers: [
          // ItemCoverWidget(item, definition, instanceInfo),
          SliverList(
              delegate: SliverChildListDelegate([
            buildSaleDetails(context),
          ]
                  .followedBy(loaded
                      ? [
                          // buildLockInfo(context),
                          // buildActionButtons(context),
                          buildLoadouts(context),
                          // buildWishlistNotes(context),
                          // buildDuplicates(context),
                          buildItemLevel(context),
                          // buildIntrinsicPerk(context),
                          // buildModInfo(context),
                          // buildStats(context),
                          // buildPerks(context),
                          // buildArmorTier(context),
                          // buildMods(context),
                          // buildWishlistBuilds(context),
                          // buildCosmetics(context),
                          // buildObjectives(context),
                          // buildRewards(context),
                          // buildQuestInfo(context),
                          // buildLore(context),
                          Container(height: 50)
                        ]
                      : [LoadingAnimWidget()])
                  .toList()))
        ],
      ),
    ]));
  }

  Widget buildLandscape(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      CustomScrollView(
        slivers: [
          SliverList(
              delegate: SliverChildListDelegate([
            buildSaleDetails(context),
          ]
                  .followedBy(loaded
                      ? [
                          // buildWishlistNotes(context),
                          // buildLockInfo(context),
                          // buildActionButtons(context),
                          // buildDuplicates(context),
                          buildItemLevel(context),
                          // buildIntrinsicPerk(context),
                          // buildModInfo(context),
                          // buildStats(context),
                          // buildPerks(context),
                          // buildArmorTier(context),
                          // buildMods(context),
                          // buildWishlistBuilds(context),
                          // buildCosmetics(context),
                          // buildObjectives(context),
                          // buildRewards(context),
                          // buildQuestInfo(context),
                          // buildLore(context),
                          Container(height: 50)
                        ]
                      : [LoadingAnimWidget()])
                  .toList()))
        ],
      ),
    ]));
  }

  Widget buildItemLevel(BuildContext context) {
    if (item == null) return Container();
    final screenPadding = MediaQuery.of(context).padding;
    return Container(
        padding: const EdgeInsets.all(8) + EdgeInsets.only(left: screenPadding.left, right: screenPadding.right),
        child: ItemLevelWidget(item: item));
  }

  Widget buildSaleDetails(BuildContext context) {
    if (vendorItem == null) {
      return Container(height: 1);
    }
    final args = routeArgs as VendorItemDetailsPageArguments;
    var screenPadding = MediaQuery.of(context).padding;
    return Container(
        padding: EdgeInsets.only(left: screenPadding.left, right: screenPadding.right),
        child: ItemVendorInfoWidget(
          sale: vendorItem,
          vendorHash: args.vendorHash,
          definition: definition,
        ));
  }

  Widget buildLoadouts(BuildContext context) {
    return ItemDetailLoadoutsWidget(item, definition, instanceInfo, loadouts: loadouts);
  }
}
