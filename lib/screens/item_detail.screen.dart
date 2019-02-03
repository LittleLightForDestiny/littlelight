import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_item_socket_entry_definition.dart';
import 'package:bungie_api/models/destiny_item_socket_state.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/enums/item_type.enum.dart';
import 'package:little_light/widgets/common/destiny_item.stateful_widget.dart';

import 'package:little_light/widgets/item_details/item_cover/item_cover.widget.dart';
import 'package:little_light/widgets/item_details/item_lore.widget.dart';
import 'package:little_light/widgets/item_details/item_mods.widget.dart';
import 'package:little_light/widgets/item_details/item_perks.widget.dart';
import 'package:little_light/widgets/item_details/item_stats.widget.dart';
import 'package:little_light/widgets/item_details/main_info/item_main_info.widget.dart';
import 'package:little_light/widgets/item_details/management_block.widget.dart';
import 'package:little_light/widgets/item_details/selected_perk.widget.dart';

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

  initState(){
    super.initState();
    this.loadDefinitions();
  }

  Future<void> loadDefinitions() async{
    if((definition.sockets?.socketEntries?.length ?? 0) > 0){
      await loadPlugDefinitions();
    }
  }

  Future<void> loadPlugDefinitions() async{
    List<int> plugHashes = definition.sockets.socketEntries.expand((socket){
      List<int> hashes = [];
      if((socket.singleInitialItemHash ?? 0) != 0){
        hashes.add(socket.singleInitialItemHash);
      }
      if((socket.reusablePlugItems?.length ?? 0) != 0){
        hashes.addAll(socket.reusablePlugItems.map((plugItem)=>plugItem.plugItemHash));
      }
      if((socket.randomizedPlugItems?.length ?? 0) != 0){
        hashes.addAll(socket.randomizedPlugItems.map((plugItem)=>plugItem.plugItemHash));
      }
      return hashes;
    }).where((i)=>i!=null).toList();
    if(item?.itemInstanceId != null){
      List<DestinyItemSocketState> socketStates = widget.profile.getItemSockets(item.itemInstanceId);
      Iterable<int> hashes = socketStates.map((state)=>state.plugHash).where((i)=>i!=null).toList();
      plugHashes.addAll(hashes);
    }
    plugDefinitions = await widget.manifest.getDefinitions<DestinyInventoryItemDefinition>(plugHashes);
    setState(() {
    });
  }  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(slivers: [
      ItemCoverWidget(item, definition, instanceInfo, uniqueId: widget.uniqueId,characterId: widget.characterId,),
      SliverList(
        delegate: SliverChildListDelegate([
          ItemMainInfoWidget(item, definition, instanceInfo),
          ManagementBlockWidget(
            item,
            definition,
            instanceInfo,
            characterId: characterId,
          ),
          buildStats(context),
          buildPerks(context),
          SelectedPerkWidget(selectedPerk,
              key: Key("selected_perk: $selectedPerk")),
          buildMods(context),
          buildQuestInfo(context),
          buildLore(context),
          Container(height: 100)
        ]),
      ),
    ]));
  }

  Widget buildStats(BuildContext context){
    return ItemStatsWidget(item, definition, instanceInfo, selectedPerks:selectedPerks, plugDefinitions:plugDefinitions, key:Key("stats_widget"));
  }

  Widget buildPerks(BuildContext context){
    return ItemPerksWidget(
            item,
            definition,
            instanceInfo,
            key:Key('perks_widget'),
            plugDefinitions: plugDefinitions,
            selectedPerkHash: selectedPerk,
            selectedPerkHashes: selectedPerks,
            onSelectPerk: (socketIndex, plugHash) {
              if (selectedPerk == plugHash) {
                selectedPerk = null;
              } else {
                selectedPerk = plugHash;
              }
              DestinyItemSocketEntryDefinition socketEntry = definition?.sockets?.socketEntries[socketIndex];
              int socketHash = socketEntry?.singleInitialItemHash ?? 0;
              if((socketEntry?.randomizedPlugItems?.length ?? 0) > 0){
                socketHash = socketEntry?.randomizedPlugItems[0].plugItemHash;
              }
              if(item?.itemInstanceId != null){
                socketHash = widget.profile.getItemSockets(item.itemInstanceId)[socketIndex].plugHash;
              }
              if(plugHash != socketHash){
                selectedPerks[socketIndex] = plugHash;
              }else{
                selectedPerks[socketIndex] = null;
              }  
              setState(() {});
            },
          );
  }

  Widget buildMods(BuildContext context){
    return ItemModsWidget(
            item,
            definition,
            instanceInfo,
            key:Key('mods_widget'),
            plugDefinitions: plugDefinitions,
            selectedModHash: selectedPerk,
            selectedModHashes: selectedPerks,
          );
  }

  Widget buildQuestInfo(BuildContext context){
    if(definition.itemType == ItemType.questStep){
      // return Container(child:QuestInfoWidget(item, definition, instanceInfo, key:Key("quest_info"), characterId:characterId));
    }
    return Container();
  }

  buildLore(BuildContext context){
    if(definition?.loreHash == null) return Container(); 
    return ItemLoreWidget(definition.loreHash);
  }
}
