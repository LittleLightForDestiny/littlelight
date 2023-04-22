// @dart=2.9

import 'package:bungie_api/enums/destiny_item_type.dart';
import 'package:bungie_api/enums/item_state.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_stat_group_definition.dart';
import 'package:bungie_api/models/destiny_vendor_sale_item_component.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/item_notes/item_notes.bloc.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_index.dart';
import 'package:little_light/modules/loadouts/blocs/loadouts.bloc.dart';
import 'package:little_light/pages/item_details/item_details.page_route.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/inventory/inventory.consumer.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/utils/socket_category_hashes.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/inventory_tabs/inventory_notification.widget.dart';
import 'package:little_light/widgets/item_details/item_collectible_info.widget.dart';
import 'package:little_light/widgets/item_details/item_cover/item_cover.widget.dart';
import 'package:little_light/widgets/item_details/item_cover/landscape_item_cover.widget.dart';
import 'package:little_light/widgets/item_details/item_detail_loadouts.widget.dart';
import 'package:little_light/widgets/item_details/item_level.widget.dart';
import 'package:little_light/widgets/item_details/item_lore.widget.dart';
import 'package:little_light/widgets/item_details/item_objectives.widget.dart';
import 'package:little_light/widgets/item_details/item_vendor_info.widget.dart';
import 'package:little_light/widgets/item_details/main_info/item_main_info.widget.dart';
import 'package:little_light/widgets/item_details/management_block.widget.dart';
import 'package:little_light/widgets/item_details/quest_info.widget.dart';
import 'package:little_light/widgets/item_details/rewards_info.widget.dart';
import 'package:little_light/widgets/item_details/wishlist_builds.widget.dart';
import 'package:little_light/widgets/item_details/wishlist_notes.widget.dart';
import 'package:little_light/widgets/item_sockets/details_armor_tier.widget.dart';
import 'package:little_light/widgets/item_sockets/details_item_intrinsic_perk.widget.dart';
import 'package:little_light/widgets/item_sockets/details_item_mods.widget.dart';
import 'package:little_light/widgets/item_sockets/details_item_perks.widget.dart';
import 'package:little_light/widgets/item_sockets/item_details_plug_info.widget.dart';
import 'package:little_light/widgets/item_sockets/item_socket.controller.dart';
import 'package:little_light/widgets/option_sheets/as_equipped_switch.widget.dart';
import 'package:little_light/widgets/option_sheets/loadout_select_sheet.widget.dart';
import 'package:provider/provider.dart';

class ItemDetailsPage extends StatefulWidget {
  const ItemDetailsPage({
    Key key,
  });

  @override
  State<ItemDetailsPage> createState() => ItemDetailScreenState();
}

class ItemDetailScreenState extends State<ItemDetailsPage>
    with AuthConsumer, ProfileConsumer, InventoryConsumer, ManifestConsumer {
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

  DestinyItemInstanceComponent get instanceInfo =>
      itemInfo?.instanceInfo ?? profile.getInstanceInfo(item?.itemInstanceId);

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
    List<ItemWithOwner> allItems = [];
    Iterable<String> charIds = profile.characters.map((char) => char.characterId);
    for (var charId in charIds) {
      allItems.addAll(profile
          .getCharacterEquipment(charId)
          .where((i) => i.itemHash == definition.hash)
          .map((item) => ItemWithOwner(item, charId)));
      allItems.addAll(profile
          .getCharacterInventory(charId)
          .where((i) => i.itemHash == definition.hash)
          .map((item) => ItemWithOwner(item, charId)));
    }
    allItems.addAll(profile
        .getProfileInventory()
        .where((i) => i.itemHash == definition.hash)
        .map((item) => ItemWithOwner(item, null)));
    duplicates = allItems.where((i) {
      return i.item.itemInstanceId != null && i.item.itemInstanceId != item?.itemInstanceId;
    }).toList();

    duplicates = await InventoryUtils.sortDestinyItems(duplicates);
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
          ItemCoverWidget(item, definition, instanceInfo),
          SliverList(
              delegate: SliverChildListDelegate([
            buildSaleDetails(context),
            ItemMainInfoWidget(
              item,
              definition,
              instanceInfo,
              characterId: characterId,
            ),
          ]
                  .followedBy(loaded
                      ? [
                          buildManagementBlock(context),
                          buildLockInfo(context),
                          buildActionButtons(context),
                          buildLoadouts(context),
                          buildWishlistNotes(context),
                          buildDuplicates(context),
                          buildItemLevel(context),
                          buildIntrinsicPerk(context),
                          buildModInfo(context),
                          // buildStats(context),
                          buildPerks(context),
                          buildArmorTier(context),
                          buildMods(context),
                          buildWishlistBuilds(context),
                          buildCosmetics(context),
                          buildObjectives(context),
                          buildRewards(context),
                          buildQuestInfo(context),
                          buildLore(context),
                          buildCollectibleInfo(context),
                          Container(height: 50)
                        ]
                      : [LoadingAnimWidget()])
                  .toList()))
        ],
      ),
      const InventoryNotificationWidget(
        key: Key('inventory_notification_widget'),
        barHeight: 0,
      ),
    ]));
  }

  Widget buildLandscape(BuildContext context) {
    final itemNotes = context.watch<ItemNotesBloc>();
    final customName = itemNotes.customNameFor(item?.itemHash, item?.itemInstanceId);
    return Scaffold(
        body: Stack(children: [
      CustomScrollView(
        slivers: [
          LandscapeItemCoverWidget(null, definition, instanceInfo,
              uniqueId: uniqueId,
              socketController: socketController,
              hideTransferBlock: hideItemManagement,
              key: Key("cover_${item?.itemHash}_${customName}_$loaded")),
          SliverList(
              delegate: SliverChildListDelegate([
            buildSaleDetails(context),
            ItemMainInfoWidget(
              item,
              definition,
              instanceInfo,
              characterId: characterId,
            ),
          ]
                  .followedBy(loaded
                      ? [
                          buildWishlistNotes(context),
                          buildManagementBlock(context),
                          buildLockInfo(context),
                          buildActionButtons(context),
                          buildDuplicates(context),
                          buildItemLevel(context),
                          buildIntrinsicPerk(context),
                          buildModInfo(context),
                          // buildStats(context),
                          buildPerks(context),
                          buildArmorTier(context),
                          buildMods(context),
                          buildWishlistBuilds(context),
                          buildCosmetics(context),
                          buildObjectives(context),
                          buildRewards(context),
                          buildQuestInfo(context),
                          buildLore(context),
                          buildCollectibleInfo(context),
                          Container(height: 50)
                        ]
                      : [LoadingAnimWidget()])
                  .toList()))
        ],
      ),
      const InventoryNotificationWidget(
        key: Key('inventory_notification_widget'),
        barHeight: 0,
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

  Widget buildWishlistNotes(BuildContext context) {
    if (item == null) return Container();
    if (socketController == null) return Container();
    var screenPadding = MediaQuery.of(context).padding;
    return Container(
        padding: EdgeInsets.only(left: screenPadding.left, right: screenPadding.right),
        child: WishlistNotesWidget(item, reusablePlugs: socketController.reusablePlugs));
  }

  Widget buildWishlistBuilds(BuildContext context) {
    var screenPadding = MediaQuery.of(context).padding;
    return Container(
        padding: EdgeInsets.only(left: screenPadding.left, right: screenPadding.right),
        child: WishlistBuildsWidget(
          definition?.hash,
          reusablePlugs: socketController.reusablePlugs,
        ));
  }

  Widget buildManagementBlock(BuildContext context) {
    if (hideItemManagement) return Container();
    var screenPadding = MediaQuery.of(context).padding;
    return Container(
        padding: EdgeInsets.only(left: screenPadding.left, right: screenPadding.right),
        child: ManagementBlockWidget(
          item,
          definition,
          instanceInfo,
          characterId: characterId,
        ));
  }

  Widget buildLockInfo(BuildContext context) {
    if (item?.lockable != true) return Container();
    var locked = item?.state?.contains(ItemState.Locked);
    return Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            Icon(locked ? FontAwesomeIcons.lock : FontAwesomeIcons.unlock, size: 14),
            Container(
              width: 4,
            ),
            Expanded(
                child: locked
                    ? TranslatedTextWidget(
                        "Item Locked",
                        uppercase: true,
                      )
                    : TranslatedTextWidget(
                        "Item Unlocked",
                        uppercase: true,
                      )),
            ElevatedButton(
              child: locked
                  ? TranslatedTextWidget(
                      "Unlock",
                      uppercase: true,
                    )
                  : TranslatedTextWidget(
                      "Lock",
                      uppercase: true,
                    ),
              onPressed: () async {
                var itemWithOwner = ItemWithOwner(item, characterId);
                inventory.changeLockState(itemWithOwner, !locked);
                setState(() {});
              },
            )
          ],
        ));
  }

  Widget buildActionButtons(BuildContext context) {
    if (hideItemManagement || item == null) return Container();
    List<Widget> buttons = [];
    if (InventoryBucket.loadoutBucketHashes.contains(definition?.inventory?.bucketTypeHash)) {
      buttons.add(Expanded(
          child: ElevatedButton(
              child: TranslatedTextWidget(
                "Add to Loadout",
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
              onPressed: () async {
                var loadouts = context.read<LoadoutsBloc>().loadouts;
                // var equipped = false;
                showModalBottomSheet(
                    context: context,
                    builder: (context) => LoadoutSelectSheet(
                        header: AsEquippedSwitchWidget(
                          onChanged: (value) {
                            // equipped = value;
                          },
                        ),
                        loadouts: loadouts,
                        onSelect: (loadout) async {
                          // loadout.addItem(item, equipped);
                          context.read<LoadoutsBloc>().saveLoadout(loadout);
                        }));
              })));
    }
    if (definition?.collectibleHash != null || definition?.equippable == true) {
      buttons.add(Expanded(
          child: ElevatedButton(
              child: TranslatedTextWidget(
                "View in Collections",
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
              onPressed: () async {
                Navigator.push(
                  context,
                  ItemDetailsPageRoute.definition(hash: definition.hash),
                );
              })));
    }
    if (buttons.isEmpty) {
      return Container();
    }
    buttons = buttons
        .expand((b) {
          return [b, Container(width: 8)];
        })
        .take(buttons.length * 2 - 1)
        .toList();
    var screenPadding = MediaQuery.of(context).padding;
    return Container(
        padding: EdgeInsets.only(left: screenPadding.left, right: screenPadding.right),
        child: Container(padding: const EdgeInsets.symmetric(horizontal: 8), child: Row(children: buttons.toList())));
  }

  Widget buildLoadouts(BuildContext context) {
    return ItemDetailLoadoutsWidget(item, definition, instanceInfo, loadouts: loadouts);
  }

  Widget buildDuplicates(context) {
    var screenPadding = MediaQuery.of(context).padding;
    return Container();
    // return Container(
    //     padding: EdgeInsets.only(left: screenPadding.left, right: screenPadding.right),
    //     child: ItemDetailDuplicatesWidget(
    //       itemWithOwner,
    //       definition,
    //       instanceInfo,
    //       duplicates: duplicates,
    //     ));
  }

  Widget buildObjectives(BuildContext context) {
    if ((definition?.objectives?.objectiveHashes?.length ?? 0) == 0) {
      return Container();
    }
    var screenPadding = MediaQuery.of(context).padding;
    return Container(
        padding: EdgeInsets.only(left: screenPadding.left, right: screenPadding.right),
        child: ItemObjectivesWidget(
            item: item,
            definition: definition,
            instanceInfo: instanceInfo,
            characterId: characterId,
            key: const Key("item_objectives_widget")));
  }

  Widget buildRewards(BuildContext context) {
    var screenPadding = MediaQuery.of(context).padding;
    return Container(
        padding: EdgeInsets.only(left: screenPadding.left, right: screenPadding.right),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: RewardsInfoWidget(item, definition, instanceInfo,
                characterId: characterId, key: const Key("item_rewards_widget"))));
  }

  Widget buildModInfo(BuildContext context) {
    var screenPadding = MediaQuery.of(context).padding;
    if (definition.itemType != DestinyItemType.Mod) return Container();
    return Container(
        padding: EdgeInsets.only(left: screenPadding.left, right: screenPadding.right),
        child: ItemDetailsPlugInfoWidget(
          item: item,
          definition: definition,
        ));
  }

  Widget buildPerks(BuildContext context) {
    var perksCategory = definition.sockets?.socketCategories
        ?.firstWhere((s) => SocketCategoryHashes.perks.contains(s.socketCategoryHash), orElse: () => null);
    if (perksCategory == null || socketController == null) return Container();
    var screenPadding = MediaQuery.of(context).padding;
    return Container(
        padding: EdgeInsets.only(left: screenPadding.left, right: screenPadding.right),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DetailsItemPerksWidget(
              controller: socketController,
              definition: definition,
              item: item,
              category: perksCategory,
              key: const Key('perks_widget'),
            )));
  }

  Widget buildIntrinsicPerk(BuildContext context) {
    var intrinsicperkCategory = definition.sockets?.socketCategories?.firstWhere(
        (s) => DestinyData.socketCategoryIntrinsicPerkHashes.contains(s.socketCategoryHash),
        orElse: () => null);
    if (intrinsicperkCategory == null || socketController == null) return Container();
    var screenPadding = MediaQuery.of(context).padding;
    return Container(
        padding: EdgeInsets.only(left: screenPadding.left, right: screenPadding.right),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DetailsItemIntrinsicPerkWidget(
              controller: socketController,
              definition: definition,
              item: item,
              category: intrinsicperkCategory,
              key: const Key('perks_widget'),
            )));
  }

  Widget buildArmorTier(BuildContext context) {
    var tierCategory = definition.sockets?.socketCategories
        ?.firstWhere((s) => DestinyData.socketCategoryTierHashes.contains(s.socketCategoryHash), orElse: () => null);
    if (tierCategory == null || socketController == null) return Container();
    var screenPadding = MediaQuery.of(context).padding;
    return Container(
        padding: EdgeInsets.only(left: screenPadding.left, right: screenPadding.right),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DetailsArmorTierWidget(
              controller: socketController,
              definition: definition,
              item: item,
              category: tierCategory,
              key: const Key('armor_tier_widget'),
            )));
  }

  Widget buildMods(BuildContext context) {
    var modsCategory = definition.sockets?.socketCategories
        ?.firstWhere((s) => SocketCategoryHashes.mods.contains(s.socketCategoryHash), orElse: () => null);
    if (modsCategory == null || socketController == null) return Container();
    var screenPadding = MediaQuery.of(context).padding;
    return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: EdgeInsets.only(left: screenPadding.left, right: screenPadding.right),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DetailsItemModsWidget(
              controller: socketController,
              definition: definition,
              item: item,
              category: modsCategory,
              key: const Key('mods_widget'),
            )));
  }

  Widget buildCosmetics(BuildContext context) {
    var modsCategory = definition.sockets?.socketCategories?.firstWhere(
        (s) => DestinyData.socketCategoryCosmeticModHashes.contains(s.socketCategoryHash),
        orElse: () => null);
    if (modsCategory == null || socketController == null) return Container();
    var screenPadding = MediaQuery.of(context).padding;
    return Container(
        padding: EdgeInsets.only(left: screenPadding.left, right: screenPadding.right),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DetailsItemModsWidget(
              controller: socketController,
              definition: definition,
              item: item,
              category: modsCategory,
              key: const Key('perks_widget'),
            )));
  }

  Widget buildQuestInfo(BuildContext context) {
    if (definition?.itemType == DestinyItemType.QuestStep) {
      var screenPadding = MediaQuery.of(context).padding;
      return Container(
          padding: EdgeInsets.only(left: screenPadding.left, right: screenPadding.right),
          child: Container(
              child: QuestInfoWidget(
                  item: item,
                  definition: definition,
                  instanceInfo: instanceInfo,
                  key: const Key("quest_info"),
                  characterId: characterId)));
    }
    return Container();
  }

  buildLore(BuildContext context) {
    if (definition?.loreHash == null) return Container();
    var screenPadding = MediaQuery.of(context).padding;
    return Container(
        padding: EdgeInsets.only(left: screenPadding.left, right: screenPadding.right),
        child: ItemLoreWidget(definition.loreHash));
  }

  buildCollectibleInfo(BuildContext context) {
    if (definition?.collectibleHash == null) return Container();
    var screenPadding = MediaQuery.of(context).padding;
    return Container(
        padding: EdgeInsets.only(left: screenPadding.left, right: screenPadding.right),
        child: ItemCollectibleInfoWidget(definition.collectibleHash));
  }
}
