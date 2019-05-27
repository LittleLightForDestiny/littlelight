import 'package:bungie_api/enums/destiny_item_type_enum.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_item_socket_entry_definition.dart';
import 'package:bungie_api/models/destiny_item_socket_state.dart';
import 'package:bungie_api/models/destiny_stat_group_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/widgets/common/destiny_item.stateful_widget.dart';
import 'package:little_light/widgets/common/perk_list_item.widget.dart';
import 'package:little_light/widgets/inventory_tabs/inventory_notification.widget.dart';
import 'package:little_light/widgets/item_details/item_collectible_info.widget.dart';

import 'package:little_light/widgets/item_details/item_cover/item_cover.widget.dart';
import 'package:little_light/widgets/item_details/item_detail_duplicates.widget.dart';
import 'package:little_light/widgets/item_details/item_lore.widget.dart';
import 'package:little_light/widgets/item_details/item_detail_mods.widget.dart';
import 'package:little_light/widgets/item_details/item_objectives.widget.dart';
import 'package:little_light/widgets/item_details/item_detail_perks.widget.dart';
import 'package:little_light/widgets/item_details/item_stats.widget.dart';
import 'package:little_light/widgets/item_details/main_info/item_main_info.widget.dart';
import 'package:little_light/widgets/item_details/management_block.widget.dart';
import 'package:little_light/widgets/item_details/quest_info.widget.dart';

class ItemDetailScreen extends DestinyItemStatefulWidget {
  final String uniqueId;

  ItemDetailScreen(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {@required String characterId,
      Key key,
      this.uniqueId})
      : super(item, definition, instanceInfo,
            key: key, characterId: characterId);

  @override
  DestinyItemState<DestinyItemStatefulWidget> createState() {
    return ItemDetailScreenState();
  }
}

class ItemDetailScreenState extends DestinyItemState<ItemDetailScreen> {
  int selectedPerk;
  Map<int, int> selectedPerks = new Map();
  Map<int, DestinyInventoryItemDefinition> plugDefinitions;
  DestinyStatGroupDefinition statGroupDefinition;
  List<ItemWithOwner> duplicates;

  initState() {
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
    allItems.sort((a, b) =>
        InventoryUtils.sortDestinyItems(a.item, b.item, widget.profile));
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
    if (item?.itemInstanceId != null) {
      List<DestinyItemSocketState> socketStates =
          widget.profile.getItemSockets(item.itemInstanceId);
      if (socketStates == null) return;
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
            ItemMainInfoWidget(item, definition, instanceInfo),
            ManagementBlockWidget(
              item,
              definition,
              instanceInfo,
              characterId: characterId,
            ),
            buildDuplicates(context),
            buildStats(context),
            buildPerks(context),
            buildSelectedPerk(context),
            buildMods(context),
            buildObjectives(context),
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
    return ItemObjectivesWidget(item, definition, instanceInfo, characterId: characterId,
        key: Key("item_objectives_widget"));
  }

  Widget buildStats(BuildContext context) {
    return ItemStatsWidget(item, definition, instanceInfo,
        selectedPerks: selectedPerks,
        plugDefinitions: plugDefinitions,
        statGroupDefinition: statGroupDefinition,
        key: Key("stats_widget_${statGroupDefinition != null}"));
  }

  Widget buildPerks(BuildContext context) {
    return ItemDetailPerksWidget(
      item,
      definition,
      instanceInfo,
      key: Key('perks_widget'),
      plugDefinitions: plugDefinitions,
      selectedPerkHash: selectedPerk,
      selectedPerkHashes: selectedPerks,
      onSelectPerk: (socketIndex, plugHash) {
        if (selectedPerk == plugHash) {
          selectedPerk = null;
        } else {
          selectedPerk = plugHash;
        }
        DestinyItemSocketEntryDefinition socketEntry =
            definition?.sockets?.socketEntries[socketIndex];
        int socketHash = socketEntry?.singleInitialItemHash ?? 0;
        if ((socketEntry?.randomizedPlugItems?.length ?? 0) > 0) {
          socketHash = socketEntry?.randomizedPlugItems[0].plugItemHash;
        }
        if (item?.itemInstanceId != null) {
          socketHash = widget.profile
              .getItemSockets(item.itemInstanceId)[socketIndex]
              .plugHash;
        }
        if (plugHash != socketHash) {
          selectedPerks[socketIndex] = plugHash;
        } else {
          selectedPerks[socketIndex] = null;
        }
        setState(() {});
      },
    );
  }

  buildSelectedPerk(BuildContext context){
    if(selectedPerk == null || !plugDefinitions.containsKey(selectedPerk)) return Container();
    return Container(
      padding: EdgeInsets.all(8),
      child:PerkListItem(definition: plugDefinitions[selectedPerk],
        alwaysOpen: true,
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
          child: QuestInfoWidget(item, definition, instanceInfo,
              key: Key("quest_info"), characterId: characterId));
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
}
