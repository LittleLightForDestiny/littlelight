import 'package:bungie_api/enums/destiny_item_type_enum.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_item_socket_state.dart';
import 'package:bungie_api/models/destiny_stat_group_definition.dart';
import 'package:bungie_api/models/destiny_vendor_sale_item_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/littlelight/loadouts.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateful_item.widget.dart';
import 'package:little_light/widgets/common/perk_list_item.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/inventory_tabs/inventory_notification.widget.dart';
import 'package:little_light/widgets/item_details/chalice_recipe.widget.dart';
import 'package:little_light/widgets/item_details/item_collectible_info.widget.dart';

import 'package:little_light/widgets/item_details/item_cover/item_cover.widget.dart';
import 'package:little_light/widgets/item_details/item_cover/landscape_item_cover.widget.dart';
import 'package:little_light/widgets/item_details/item_detail_duplicates.widget.dart';
import 'package:little_light/widgets/item_details/item_lore.widget.dart';
import 'package:little_light/widgets/item_details/item_detail_mods.widget.dart';
import 'package:little_light/widgets/item_details/item_objectives.widget.dart';
import 'package:little_light/widgets/item_details/item_stats.widget.dart';
import 'package:little_light/widgets/item_details/item_vendor_info.widget.dart';
import 'package:little_light/widgets/item_details/main_info/item_main_info.widget.dart';
import 'package:little_light/widgets/item_details/management_block.widget.dart';
import 'package:little_light/widgets/item_details/quest_info.widget.dart';
import 'package:little_light/widgets/item_details/rewards_info.widget.dart';
import 'package:little_light/widgets/item_sockets/details_item_perks.widget.dart';
import 'package:little_light/widgets/item_sockets/item_socket.controller.dart';
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
  Map<int, DestinyInventoryItemDefinition> plugDefinitions;
  DestinyStatGroupDefinition statGroupDefinition;
  List<ItemWithOwner> duplicates;

  List<DestinyItemSocketState> get socketStates =>
      widget.socketStates ??
      widget.profile.getItemSockets(item?.itemInstanceId);

  initState() {
    socketController =
        ItemSocketController(definition: widget.definition, item: widget.item);
    super.initState();
    this.loadDefinitions();
  }

  Future<void> loadDefinitions() async {
    findDuplicates();
    if ((definition?.sockets?.socketEntries?.length ?? 0) > 0) {
      await loadPlugDefinitions();
    }
    loadStatGroupDefinition();
  }

  findDuplicates() {
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
    allItems.sort((a, b) => InventoryUtils.sortDestinyItems(a.item, b.item));
    duplicates = allItems.where((i) {
      return i.item.itemInstanceId != null &&
          i.item.itemInstanceId != item?.itemInstanceId;
    }).toList();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> loadPlugDefinitions() async {
    List<int> plugHashes = definition.sockets.socketEntries
        .expand((socket) {
          List<int> hashes = [];
          if ((socket.singleInitialItemHash ?? 0) != 0) {
            hashes.add(socket.singleInitialItemHash);
          }
          if ((socket.reusablePlugItems?.length ?? 0) != 0) {
            hashes.addAll(socket.reusablePlugItems
                .map((plugItem) => plugItem.plugItemHash));
          }
          if ((socket.randomizedPlugItems?.length ?? 0) != 0) {
            hashes.addAll(socket.randomizedPlugItems
                .map((plugItem) => plugItem.plugItemHash));
          }
          return hashes;
        })
        .where((i) => i != null)
        .toList();
    if (socketStates != null) {
      Iterable<int> hashes = socketStates
          .map((state) => state.plugHash)
          .where((i) => i != null)
          .toList();
      plugHashes.addAll(hashes);
    }
    plugDefinitions = await widget.manifest
        .getDefinitions<DestinyInventoryItemDefinition>(plugHashes);
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
    return Scaffold(
        body: Stack(children: [
      CustomScrollView(
        slivers: [
          ItemCoverWidget(
            item,
            definition,
            instanceInfo,
            uniqueId: widget.uniqueId,
            characterId: widget.characterId,
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            buildSaleDetails(context),
            ItemMainInfoWidget(item, definition, instanceInfo),
            buildManagementBlock(context),
            buildAddToLoadoutButton(context),
            buildDuplicates(context),
            buildStats(context),
            buildPerks(context),
            buildSelectedPerk(context),
            buildMods(context),
            buildObjectives(context),
            buildRewards(context),
            buildQuestInfo(context),
            buildLore(context),
            buildCollectibleInfo(context),
            buildRecipesInfo(context),
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
    return Scaffold(
        body: Stack(children: [
      CustomScrollView(
        slivers: [
          LandscapeItemCoverWidget(
            item,
            definition,
            instanceInfo,
            uniqueId: widget.uniqueId,
            characterId: widget.characterId,
            plugDefinitions: plugDefinitions,
            socketController: socketController,
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            buildSaleDetails(context),
            buildManagementBlock(context),
            buildAddToLoadoutButton(context),
            buildDuplicates(context),
            buildPerks(context),
            buildSelectedPerk(context),
            buildMods(context),
            buildObjectives(context),
            buildRewards(context),
            buildQuestInfo(context),
            buildLore(context),
            buildCollectibleInfo(context),
            buildRecipesInfo(context),
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
    if (widget.sale == null) {
      return Container();
    }
    return ItemVendorInfoWidget(
      sale: widget.sale,
      vendorHash: widget.vendorHash,
      definition: definition,
    );
  }

  Widget buildManagementBlock(BuildContext context) {
    if (widget.hideItemManagement) return Container();
    return ManagementBlockWidget(
      item,
      definition,
      instanceInfo,
      characterId: characterId,
    );
  }

  Widget buildAddToLoadoutButton(BuildContext context) {
    if (widget.hideItemManagement) return Container();
    if (widget.item == null ||
        !loadoutBucketHashes.contains(definition?.inventory?.bucketTypeHash)) {
      return Container();
    }
    return Container(
        padding: EdgeInsets.all(8),
        child: RaisedButton(
            child: TranslatedTextWidget("Add to Loadout"),
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
            }));
  }

  Widget buildDuplicates(context) {
    return ItemDetailDuplicatesWidget(
      item,
      definition,
      instanceInfo,
      duplicates: duplicates,
    );
  }

  Widget buildObjectives(BuildContext context) {
    if ((definition?.objectives?.objectiveHashes?.length ?? 0) == 0) {
      return Container();
    }
    return ItemObjectivesWidget(
        item: item,
        definition: definition,
        instanceInfo: instanceInfo,
        characterId: characterId,
        key: Key("item_objectives_widget"));
  }

  Widget buildRewards(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(8),
        child: RewardsInfoWidget(item, definition, instanceInfo,
            characterId: characterId, key: Key("item_rewards_widget")));
  }

  Widget buildStats(BuildContext context) {
    return ItemStatsWidget(item, definition, instanceInfo,
        selectedPerks: selectedPerks,
        plugDefinitions: plugDefinitions,
        statGroupDefinition: statGroupDefinition,
        key: Key("stats_widget_${statGroupDefinition != null}"));
  }

  Widget buildPerks(BuildContext context) {
    var perksCategory = definition.sockets?.socketCategories?.firstWhere(
        (s) =>
            DestinyData.socketCategoryPerkHashes.contains(s.socketCategoryHash),
        orElse: () => null);
    if(perksCategory == null) return Container();
    return Container(
      padding: EdgeInsets.all(8),
        child: DetailsItemPerksWidget(
      controller: socketController,
      definition: definition,
      item: item,
      category: perksCategory,
      key: Key('perks_widget'),
    ));
  }

  buildSelectedPerk(BuildContext context) {
    if (selectedPerk == null || !plugDefinitions.containsKey(selectedPerk))
      return Container();
    return Container(
        padding: EdgeInsets.all(8),
        child: PerkListItem(
            definition: plugDefinitions[selectedPerk],
            key: Key("selected_perk: $selectedPerk")));
  }

  Widget buildMods(BuildContext context) {
    return ItemDetailModsWidget(
      item,
      definition,
      instanceInfo,
      key: Key('mods_widget'),
      plugDefinitions: plugDefinitions,
    );
  }

  Widget buildQuestInfo(BuildContext context) {
    if (definition?.itemType == DestinyItemType.QuestStep) {
      return Container(
          child: QuestInfoWidget(
              item: item,
              definition: definition,
              instanceInfo: instanceInfo,
              key: Key("quest_info"),
              characterId: characterId));
    }
    return Container();
  }

  buildLore(BuildContext context) {
    if (definition?.loreHash == null) return Container();
    return ItemLoreWidget(definition.loreHash);
  }

  buildCollectibleInfo(BuildContext context) {
    if (definition?.collectibleHash == null) return Container();
    return ItemCollectibleInfoWidget(definition.collectibleHash);
  }

  buildRecipesInfo(BuildContext context) {
    return ChaliceRecipeWidget(definition);
  }
}
