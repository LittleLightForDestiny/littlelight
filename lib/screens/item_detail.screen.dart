import 'package:bungie_api/enums/destiny_item_type.dart';
import 'package:bungie_api/enums/item_state.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_item_socket_state.dart';
import 'package:bungie_api/models/destiny_stat_group_definition.dart';
import 'package:bungie_api/models/destiny_vendor_sale_item_component.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/inventory/inventory.service.dart';
import 'package:little_light/services/littlelight/item_notes.service.dart';
import 'package:little_light/services/littlelight/loadouts.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateful_item.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/inventory_tabs/inventory_notification.widget.dart';
import 'package:little_light/widgets/item_details/item_collectible_info.widget.dart';
import 'package:little_light/widgets/item_details/item_cover/item_cover.widget.dart';
import 'package:little_light/widgets/item_details/item_cover/landscape_item_cover.widget.dart';
import 'package:little_light/widgets/item_details/item_detail_duplicates.widget.dart';
import 'package:little_light/widgets/item_details/item_detail_loadouts.widget.dart';
import 'package:little_light/widgets/item_details/item_lore.widget.dart';
import 'package:little_light/widgets/item_details/item_objectives.widget.dart';
import 'package:little_light/widgets/item_details/item_vendor_info.widget.dart';
import 'package:little_light/widgets/item_details/main_info/item_main_info.widget.dart';
import 'package:little_light/widgets/item_details/management_block.widget.dart';
import 'package:little_light/widgets/item_details/quest_info.widget.dart';
import 'package:little_light/widgets/item_details/rewards_info.widget.dart';
import 'package:little_light/widgets/item_details/wishlist_notes.widget.dart';
import 'package:little_light/widgets/item_notes/item_details_notes.widget.dart';
import 'package:little_light/widgets/item_sockets/details_armor_tier.widget.dart';
import 'package:little_light/widgets/item_sockets/details_item_intrinsic_perk.widget.dart';
import 'package:little_light/widgets/item_sockets/details_item_mods.widget.dart';
import 'package:little_light/widgets/item_sockets/details_item_perks.widget.dart';
import 'package:little_light/widgets/item_sockets/item_details_plug_info.widget.dart';
import 'package:little_light/widgets/item_sockets/item_details_socket_details.widget.dart';
import 'package:little_light/widgets/item_sockets/item_socket.controller.dart';
import 'package:little_light/widgets/item_stats/details_item_stats.widget.dart';
import 'package:little_light/widgets/item_tags/item_details_tags.widget.dart';
import 'package:little_light/widgets/option_sheets/as_equipped_switch.widget.dart';
import 'package:little_light/widgets/option_sheets/loadout_select_sheet.widget.dart';

class ItemDetailScreen extends BaseDestinyStatefulItemWidget {
  final String uniqueId;
  final bool hideItemManagement;
  final List<DestinyItemSocketState> socketStates;
  final DestinyVendorSaleItemComponent sale;
  final int vendorHash;

  ItemDetailScreen(
      {String characterId,
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      this.vendorHash,
      this.hideItemManagement = false,
      this.socketStates,
      Key key,
      this.uniqueId,
      this.sale})
      : super(
            item: item,
            definition: definition,
            instanceInfo: instanceInfo,
            key: key,
            characterId: characterId);

  @override
  BaseDestinyItemState<BaseDestinyStatefulItemWidget> createState() {
    return ItemDetailScreenState();
  }
}

class ItemDetailScreenState extends BaseDestinyItemState<ItemDetailScreen> {
  int selectedPerk;
  Map<int, int> selectedPerks = new Map();
  ItemSocketController socketController;
  DestinyStatGroupDefinition statGroupDefinition;
  List<ItemWithOwner> duplicates;
  List<Loadout> loadouts;

  List<DestinyItemSocketState> get socketStates =>
      widget.socketStates ??
      widget.profile.getItemSockets(item?.itemInstanceId);

  initState() {
    super.initState();
    socketController =
        ItemSocketController(definition: widget.definition, item: widget.item);
    this.loadDefinitions();
  }

  Future<void> loadDefinitions() async {
    findLoadouts();
    findDuplicates();
    loadStatGroupDefinition();
  }

  findLoadouts() async {
    var allLoadouts = await LoadoutsService().getLoadouts();
    loadouts = allLoadouts.where((loadout) {
      var equip = loadout.equipped
          .where((element) => element.itemInstanceId == item?.itemInstanceId);
      var unequip = loadout.unequipped
          .where((element) => element.itemInstanceId == item?.itemInstanceId);
      return equip.length > 0 || unequip.length > 0;
    }).toList();
  }

  findDuplicates() async {
    AuthService auth = AuthService();
    if (!auth.isLogged) {
      return;
    }
    List<ItemWithOwner> allItems = [];
    Iterable<String> charIds =
        widget.profile.getCharacters().map((char) => char.characterId);
    charIds.forEach((charId) {
      allItems.addAll(widget.profile
          .getCharacterEquipment(charId)
          .where((i) => i.itemHash == this.definition.hash)
          .map((item) => ItemWithOwner(item, charId)));
      allItems.addAll(widget.profile
          .getCharacterInventory(charId)
          .where((i) => i.itemHash == this.definition.hash)
          .map((item) => ItemWithOwner(item, charId)));
    });
    allItems.addAll(widget.profile
        .getProfileInventory()
        .where((i) => i.itemHash == this.definition.hash)
        .map((item) => ItemWithOwner(item, null)));
    duplicates = allItems.where((i) {
      return i.item.itemInstanceId != null &&
          i.item.itemInstanceId != item?.itemInstanceId;
    }).toList();

    duplicates = await InventoryUtils.sortDestinyItems(duplicates);

    if (mounted) {
      setState(() {});
    }
  }

  Future loadStatGroupDefinition() async {
    if (definition?.stats?.statGroupHash != null) {
      statGroupDefinition = await widget.manifest
          .getDefinition<DestinyStatGroupDefinition>(
              definition?.stats?.statGroupHash);
      if (mounted) {
        setState(() {});
      }
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
    var customName = ItemNotesService()
        .getNotesForItem(item?.itemHash, item?.itemInstanceId)
        ?.customName;
    return Scaffold(
        body: Stack(children: [
      CustomScrollView(
        slivers: [
          ItemCoverWidget(item, definition, instanceInfo,
              uniqueId: widget.uniqueId,
              characterId: widget.characterId,
              key: Key("cover_$customName")),
          SliverList(
              delegate: SliverChildListDelegate([
            buildSaleDetails(context),
            ItemMainInfoWidget(
              item,
              definition,
              instanceInfo,
              characterId: characterId,
            ),
            buildManagementBlock(context),
            buildLockInfo(context),
            buildActionButtons(context),
            buildLoadouts(context),
            buildWishlistNotes(context),
            buildDuplicates(context),
            buildIntrinsicPerk(context),
            buildExoticPerkDetails(context),
            buildModInfo(context),
            buildStats(context),
            buildPerks(context),
            buildPerkDetails(context),
            buildArmorTier(context),
            buildMods(context),
            buildModDetails(context),
            buildCosmetics(context),
            buildCosmeticDetails(context),
            buildNotes(context),
            buildTags(context),
            buildObjectives(context),
            buildRewards(context),
            buildQuestInfo(context),
            buildLore(context),
            buildCollectibleInfo(context),
            Container(height: 50)
          ]))
        ],
      ),
      InventoryNotificationWidget(
        key: Key('inventory_notification_widget'),
        barHeight: 0,
      ),
    ]));
  }

  Widget buildLandscape(BuildContext context) {
    var customName = ItemNotesService()
        .getNotesForItem(item?.itemHash, item?.itemInstanceId)
        ?.customName;
    return Scaffold(
        body: Stack(children: [
      CustomScrollView(
        slivers: [
          LandscapeItemCoverWidget(item, definition, instanceInfo,
              uniqueId: widget.uniqueId,
              characterId: widget.characterId,
              socketController: socketController,
              hideTransferBlock: widget.hideItemManagement,
              key: Key("cover_${item?.itemHash}_$customName")),
          SliverList(
              delegate: SliverChildListDelegate([
            buildSaleDetails(context),
            ItemMainInfoWidget(
              item,
              definition,
              instanceInfo,
              characterId: characterId,
            ),
            buildWishlistNotes(context),
            buildManagementBlock(context),
            buildLockInfo(context),
            buildActionButtons(context),
            buildDuplicates(context),
            buildIntrinsicPerk(context),
            buildExoticPerkDetails(context),
            buildModInfo(context),
            buildStats(context),
            buildPerks(context),
            buildPerkDetails(context),
            buildArmorTier(context),
            buildMods(context),
            buildModDetails(context),
            buildCosmetics(context),
            buildCosmeticDetails(context),
            buildNotes(context),
            buildTags(context),
            buildObjectives(context),
            buildRewards(context),
            buildQuestInfo(context),
            buildLore(context),
            buildCollectibleInfo(context),
            Container(height: 50)
          ]))
        ],
      ),
      InventoryNotificationWidget(
        key: Key('inventory_notification_widget'),
        barHeight: 0,
      ),
    ]));
  }

  Widget buildSaleDetails(BuildContext context) {
    if (widget?.sale == null) {
      return Container(height: 1);
    }
    var screenPadding = MediaQuery.of(context).padding;
    return Container(
        padding: EdgeInsets.only(
            left: screenPadding.left, right: screenPadding.right),
        child: ItemVendorInfoWidget(
          sale: widget.sale,
          vendorHash: widget.vendorHash,
          definition: definition,
        ));
  }

  Widget buildWishlistNotes(BuildContext context) {
    if (item == null) return Container();
    var screenPadding = MediaQuery.of(context).padding;
    return Container(
        padding: EdgeInsets.only(
            left: screenPadding.left, right: screenPadding.right),
        child: WishlistNotesWidget(
          item,
        ));
  }

  Widget buildManagementBlock(BuildContext context) {
    if (widget.hideItemManagement) return Container();
    var screenPadding = MediaQuery.of(context).padding;
    return Container(
        padding: EdgeInsets.only(
            left: screenPadding.left, right: screenPadding.right),
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
        padding: EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            Icon(locked ? FontAwesomeIcons.lock : FontAwesomeIcons.unlock,
                size: 14),
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
                InventoryService().changeLockState(itemWithOwner, !locked);
                setState(() {});
              },
            )
          ],
        ));
  }

  Widget buildActionButtons(BuildContext context) {
    if (widget.hideItemManagement || widget.item == null) return Container();
    List<Widget> buttons = [];
    if (InventoryBucket.loadoutBucketHashes
        .contains(definition?.inventory?.bucketTypeHash)) {
      buttons.add(Expanded(
          child: ElevatedButton(
              child: TranslatedTextWidget(
                "Add to Loadout",
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
              onPressed: () async {
                var loadouts = await LoadoutsService().getLoadouts();
                var equipped = false;
                showModalBottomSheet(
                    context: context,
                    builder: (context) => LoadoutSelectSheet(
                        header: AsEquippedSwitchWidget(
                          onChanged: (value) {
                            equipped = value;
                          },
                        ),
                        loadouts: loadouts,
                        onSelect: (loadout) async {
                          loadout.addItem(widget.item.itemHash,
                              widget.item.itemInstanceId, equipped);
                          await LoadoutsService().saveLoadout(loadout);
                        }));
              })));
    }
    if (widget?.definition?.collectibleHash != null ||
        widget?.definition?.equippable == true) {
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
                  MaterialPageRoute(
                    builder: (context) => ItemDetailScreen(
                      definition: widget.definition,
                      uniqueId: null,
                    ),
                  ),
                );
              })));
    }
    if (buttons.length == 0) {
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
        padding: EdgeInsets.only(
            left: screenPadding.left, right: screenPadding.right),
        child: Container(
            padding: EdgeInsets.all(8),
            child: Row(children: buttons.toList())));
  }

  Widget buildLoadouts(BuildContext context) {
    return ItemDetailLoadoutsWidget(item, definition, instanceInfo,
        loadouts: loadouts);
  }

  Widget buildDuplicates(context) {
    var screenPadding = MediaQuery.of(context).padding;
    return Container(
        padding: EdgeInsets.only(
            left: screenPadding.left, right: screenPadding.right),
        child: ItemDetailDuplicatesWidget(
          item,
          definition,
          instanceInfo,
          duplicates: duplicates,
        ));
  }

  Widget buildNotes(BuildContext context) {
    var screenPadding = MediaQuery.of(context).padding;
    if (item == null) return Container(height: 1);
    return Container(
        padding: EdgeInsets.only(
            left: screenPadding.left, right: screenPadding.right),
        child: ItemDetailsNotesWidget(
            item: item,
            definition: definition,
            instanceInfo: instanceInfo,
            characterId: characterId,
            onUpdate: () {
              setState(() => {});
            },
            key: Key("item_notes")));
  }

  Widget buildTags(BuildContext context) {
    var screenPadding = MediaQuery.of(context).padding;
    if (item == null) return Container();
    return Container(
        padding: EdgeInsets.only(
            left: screenPadding.left, right: screenPadding.right),
        child: ItemDetailsTagsWidget(
            item: item,
            definition: definition,
            instanceInfo: instanceInfo,
            characterId: characterId,
            onUpdate: () {
              setState(() => {});
            },
            key: Key("item_tags_widget")));
  }

  Widget buildObjectives(BuildContext context) {
    if ((definition?.objectives?.objectiveHashes?.length ?? 0) == 0) {
      return Container();
    }
    var screenPadding = MediaQuery.of(context).padding;
    return Container(
        padding: EdgeInsets.only(
            left: screenPadding.left, right: screenPadding.right),
        child: ItemObjectivesWidget(
            item: item,
            definition: definition,
            instanceInfo: instanceInfo,
            characterId: characterId,
            key: Key("item_objectives_widget")));
  }

  Widget buildRewards(BuildContext context) {
    var screenPadding = MediaQuery.of(context).padding;
    return Container(
        padding: EdgeInsets.only(
            left: screenPadding.left, right: screenPadding.right),
        child: Container(
            padding: EdgeInsets.all(8),
            child: RewardsInfoWidget(item, definition, instanceInfo,
                characterId: characterId, key: Key("item_rewards_widget"))));
  }

  Widget buildModInfo(BuildContext context) {
    var screenPadding = MediaQuery.of(context).padding;
    if (definition.itemType != DestinyItemType.Mod) return Container();
    return Container(
        padding: EdgeInsets.only(
            left: screenPadding.left, right: screenPadding.right),
        child: ItemDetailsPlugInfoWidget(
          item: item,
          definition: definition,
        ));
  }

  Widget buildStats(BuildContext context) {
    var screenPadding = MediaQuery.of(context).padding;
    return Container(
        padding: EdgeInsets.only(
            left: screenPadding.left, right: screenPadding.right),
        child: DetailsItemStatsWidget(
            item: item,
            definition: definition,
            socketController: socketController,
            key: Key("stats_widget")));
  }

  Widget buildPerks(BuildContext context) {
    var perksCategory = definition.sockets?.socketCategories?.firstWhere(
        (s) =>
            DestinyData.socketCategoryPerkHashes.contains(s.socketCategoryHash),
        orElse: () => null);
    if (perksCategory == null) return Container();
    var screenPadding = MediaQuery.of(context).padding;
    return Container(
        padding: EdgeInsets.only(
            left: screenPadding.left, right: screenPadding.right),
        child: Container(
            padding: EdgeInsets.all(8),
            child: DetailsItemPerksWidget(
              controller: socketController,
              definition: definition,
              item: item,
              category: perksCategory,
              key: Key('perks_widget'),
            )));
  }

  Widget buildIntrinsicPerk(BuildContext context) {
    var intrinsicperkCategory = definition.sockets?.socketCategories
        ?.firstWhere(
            (s) => DestinyData.socketCategoryIntrinsicPerkHashes
                .contains(s.socketCategoryHash),
            orElse: () => null);
    if (intrinsicperkCategory == null) return Container();
    var screenPadding = MediaQuery.of(context).padding;
    return Container(
        padding: EdgeInsets.only(
            left: screenPadding.left, right: screenPadding.right),
        child: Container(
            padding: EdgeInsets.all(8),
            child: DetailsItemIntrinsicPerkWidget(
              controller: socketController,
              definition: definition,
              item: item,
              category: intrinsicperkCategory,
              key: Key('perks_widget'),
            )));
  }

  Widget buildArmorTier(BuildContext context) {
    var tierCategory = definition.sockets?.socketCategories?.firstWhere(
        (s) =>
            DestinyData.socketCategoryTierHashes.contains(s.socketCategoryHash),
        orElse: () => null);
    if (tierCategory == null) return Container();
    var screenPadding = MediaQuery.of(context).padding;
    return Container(
        padding: EdgeInsets.only(
            left: screenPadding.left, right: screenPadding.right),
        child: Container(
            padding: EdgeInsets.all(8),
            child: DetailsArmorTierWidget(
              controller: socketController,
              definition: definition,
              item: item,
              category: tierCategory,
              key: Key('armor_tier_widget'),
            )));
  }

  Widget buildPerkDetails(BuildContext context) {
    var perksCategory = definition.sockets?.socketCategories?.firstWhere(
        (s) =>
            DestinyData.socketCategoryPerkHashes.contains(s.socketCategoryHash),
        orElse: () => null);
    if (perksCategory == null) return Container();
    var screenPadding = MediaQuery.of(context).padding;
    return Container(
        padding: EdgeInsets.only(
            left: screenPadding.left, right: screenPadding.right),
        child: Container(
            padding: EdgeInsets.all(8),
            child: ItemDetailsSocketDetailsWidget(
              controller: socketController,
              parentDefinition: definition,
              item: item,
              category: perksCategory,
            )));
  }

  Widget buildExoticPerkDetails(BuildContext context) {
    var perksCategory = definition.sockets?.socketCategories?.firstWhere(
        (s) => DestinyData.socketCategoryIntrinsicPerkHashes
            .contains(s.socketCategoryHash),
        orElse: () => null);
    if (perksCategory == null) return Container();
    var screenPadding = MediaQuery.of(context).padding;
    return Container(
        padding: EdgeInsets.only(
            left: screenPadding.left, right: screenPadding.right),
        child: Container(
            padding: EdgeInsets.all(8),
            child: ItemDetailsSocketDetailsWidget(
              controller: socketController,
              parentDefinition: definition,
              item: item,
              category: perksCategory,
            )));
  }

  Widget buildMods(BuildContext context) {
    var modsCategory = definition.sockets?.socketCategories?.firstWhere(
        (s) =>
            DestinyData.socketCategoryModHashes.contains(s.socketCategoryHash),
        orElse: () => null);
    if (modsCategory == null) return Container();
    var screenPadding = MediaQuery.of(context).padding;
    return Container(
        padding: EdgeInsets.only(
            left: screenPadding.left, right: screenPadding.right),
        child: Container(
            padding: EdgeInsets.all(8),
            child: DetailsItemModsWidget(
              controller: socketController,
              definition: definition,
              item: item,
              category: modsCategory,
              key: Key('mods_widget'),
            )));
  }

  Widget buildModDetails(BuildContext context) {
    var modsCategory = definition.sockets?.socketCategories?.firstWhere(
        (s) =>
            DestinyData.socketCategoryModHashes.contains(s.socketCategoryHash),
        orElse: () => null);
    if (modsCategory == null) return Container();
    var screenPadding = MediaQuery.of(context).padding;
    return Container(
        padding: EdgeInsets.only(
            left: screenPadding.left, right: screenPadding.right),
        child: Container(
            padding: EdgeInsets.all(8),
            child: ItemDetailsSocketDetailsWidget(
              controller: socketController,
              parentDefinition: definition,
              item: item,
              category: modsCategory,
            )));
  }

  Widget buildCosmetics(BuildContext context) {
    var modsCategory = definition.sockets?.socketCategories?.firstWhere(
        (s) => DestinyData.socketCategoryCosmeticModHashes
            .contains(s.socketCategoryHash),
        orElse: () => null);
    if (modsCategory == null) return Container();
    var screenPadding = MediaQuery.of(context).padding;
    return Container(
        padding: EdgeInsets.only(
            left: screenPadding.left, right: screenPadding.right),
        child: Container(
            padding: EdgeInsets.all(8),
            child: DetailsItemModsWidget(
              controller: socketController,
              definition: definition,
              item: item,
              category: modsCategory,
              key: Key('perks_widget'),
            )));
  }

  Widget buildCosmeticDetails(BuildContext context) {
    var modsCategory = definition.sockets?.socketCategories?.firstWhere(
        (s) => DestinyData.socketCategoryCosmeticModHashes
            .contains(s.socketCategoryHash),
        orElse: () => null);
    if (modsCategory == null) return Container();
    var screenPadding = MediaQuery.of(context).padding;
    return Container(
        padding: EdgeInsets.only(
            left: screenPadding.left, right: screenPadding.right),
        child: Container(
            padding: EdgeInsets.all(8),
            child: ItemDetailsSocketDetailsWidget(
              controller: socketController,
              parentDefinition: definition,
              item: item,
              category: modsCategory,
            )));
  }

  Widget buildQuestInfo(BuildContext context) {
    if (definition?.itemType == DestinyItemType.QuestStep) {
      var screenPadding = MediaQuery.of(context).padding;
      return Container(
          padding: EdgeInsets.only(
              left: screenPadding.left, right: screenPadding.right),
          child: Container(
              child: QuestInfoWidget(
                  item: item,
                  definition: definition,
                  instanceInfo: instanceInfo,
                  key: Key("quest_info"),
                  characterId: characterId)));
    }
    return Container();
  }

  buildLore(BuildContext context) {
    if (definition?.loreHash == null) return Container();
    var screenPadding = MediaQuery.of(context).padding;
    return Container(
        padding: EdgeInsets.only(
            left: screenPadding.left, right: screenPadding.right),
        child: ItemLoreWidget(definition.loreHash));
  }

  buildCollectibleInfo(BuildContext context) {
    if (definition?.collectibleHash == null) return Container();
    var screenPadding = MediaQuery.of(context).padding;
    return Container(
        padding: EdgeInsets.only(
            left: screenPadding.left, right: screenPadding.right),
        child: ItemCollectibleInfoWidget(definition.collectibleHash));
  }
}
