import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/destiny_item.stateful_widget.dart';

import 'package:little_light/widgets/item_details/item_cover/item_cover.widget.dart';
import 'package:little_light/widgets/item_details/item_lore.widget.dart';
import 'package:little_light/widgets/item_details/item_perks.widget.dart';
import 'package:little_light/widgets/item_details/item_stats.widget.dart';
import 'package:little_light/widgets/item_details/main_info/item_main_info.widget.dart';
import 'package:little_light/widgets/item_details/management_block.widget.dart';
import 'package:little_light/widgets/item_details/selected_perk.widget.dart';

class ItemDetailScreen extends DestinyItemStatefulWidget {
  ItemDetailScreen(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {@required String characterId,
      Key key})
      : super(item, definition, instanceInfo,
            key: key, characterId: characterId);

  @override
  DestinyItemState<DestinyItemStatefulWidget> createState() {
    return ItemDetailScreenState();
  }
}

class ItemDetailScreenState extends DestinyItemState {
  int selectedPerk;
  Map<int, int> selectedPerks = new Map();
  Map<int, DestinyInventoryItemDefinition> plugDefinitions;

  initState(){
    super.initState();
    this.loadPlugDefinitions();
  }

  Future<void> loadDefinitions() async{
    if(definition.sockets?.socketEntries?.length ?? 0 > 0){
      await loadPlugDefinitions();
    }
    setState(() {
      plugDefinitions = plugDefinitions;
    });
  }

  Future<void> loadPlugDefinitions() async{
    List<int> plugHashes = definition.sockets.socketEntries.expand((socket){
      List<int> hashes = [];
      if(socket.reusablePlugItems != null){
        hashes.addAll(socket.reusablePlugItems.map((plugItem)=>plugItem.plugItemHash));
      }
      if(socket.randomizedPlugItems != null){
        hashes.addAll(socket.randomizedPlugItems.map((plugItem)=>plugItem.plugItemHash));
      }
      return hashes;
    }).where((i)=>i!=null).toList();
    plugDefinitions = await widget.manifest.getDefinitions<DestinyInventoryItemDefinition>(plugHashes);
  }  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(slivers: [
      ItemCoverWidget(item, definition, instanceInfo),
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
          buildLore(context),
          Container(height: 500)
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
            plugDefinitions: plugDefinitions,
            selectedPerkHash: selectedPerk,
            selectedPerkHashes: selectedPerks,
            onSelectPerk: (socketHash, plugHash) {
              if (selectedPerk == plugHash) {
                selectedPerk = null;
              } else {
                selectedPerk = plugHash;
              }
              if(plugHash != socketHash){
                selectedPerks[socketHash] = plugHash;
              }else{
                selectedPerks[socketHash] = null;
              }  
              setState(() {});
            },
          );
  }

  buildLore(BuildContext context){
    if(definition?.loreHash == null) return Container(); 
    return ItemLoreWidget(definition.loreHash);
  }
}
