import 'package:bungie_api/enums/destiny_socket_category_style_enum.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_item_socket_entry_definition.dart';
import 'package:bungie_api/models/destiny_item_socket_state.dart';
import 'package:bungie_api/models/destiny_socket_category_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/destiny_item.stateful_widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

class ItemPerksWidget extends DestinyItemStatefulWidget {
  final double iconSize;
  ItemPerksWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key,
      String characterId,
      this.iconSize = 16})
      : super(item, definition, instanceInfo,
            key: key, characterId: characterId);

  @override
  ItemPerksWidgetState createState() {
    return ItemPerksWidgetState();
  }
}

class ItemPerksWidgetState extends DestinyItemState<ItemPerksWidget> {
  DestinySocketCategoryDefinition perksCatDefinition;

  @override
  void initState() {
    super.initState();
    loadPerks();
  }

  loadPerks() async {
    if(definition?.sockets?.socketCategories == null){
      return;
    }
    var socketCategoryHashes =
        definition.sockets.socketCategories.map((s) => s.socketCategoryHash);
    var socketCategoryDefinitions = await widget.manifest
        .getDefinitions<DestinySocketCategoryDefinition>(socketCategoryHashes);
    perksCatDefinition = socketCategoryDefinitions.values.firstWhere((def) {
      return def.categoryStyle & DestinySocketCategoryStyle.Reusable ==
          DestinySocketCategoryStyle.Reusable;
    }, orElse: ()=>null);
    if(!mounted) return;
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
    if(socketCategory == null) return Container();
    socketCategory.socketIndexes.forEach((index) {
      var hash = item != null ? getEquippedPlugHashBySocketIndex(index) : getDefaultPerkBySocketIndex(index);
      columns.add(buildPerkIcon(context, hash));
    });
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: columns.toList());
  }

  Widget buildPerkIcon(BuildContext context, int plugHash) {
    if(plugHash == null){
      return Container();
    }
    return Container(
      width: widget.iconSize,
      height: widget.iconSize,
      child: ManifestImageWidget<DestinyInventoryItemDefinition>(plugHash, placeholder: Container(),),
    );
  }

  DestinyItemSocketState getSocketState(int index){
    if(item?.itemInstanceId == null) return null;
    List<DestinyItemSocketState> socketStates =
        widget.profile.getItemSockets(item.itemInstanceId);
    return socketStates[index];
  }

  int getEquippedPlugHashBySocketIndex(int index) {
    var entry = socketEntries[index];
    var state = getSocketState(index);
    if(!(state.isVisible ?? false)){
      return null;
    }
    if((state?.plugHash ?? 0) != 0){
      return state?.plugHash;
    }
    if((entry.singleInitialItemHash ?? 0) != 0){
      return entry.singleInitialItemHash;
    }
    return null;
  }


  int getDefaultPerkBySocketIndex(int index) {
    var entry = socketEntries[index];
    if((entry.singleInitialItemHash ?? 0) != 0){
      return entry.singleInitialItemHash;
    }
    if((entry.reusablePlugItems?.length ?? 0) != 0){
      return entry.reusablePlugItems[0].plugItemHash;
    }
    return null;
  }

  List<DestinyItemSocketEntryDefinition> get socketEntries {
    return definition.sockets.socketEntries;
  }
}
