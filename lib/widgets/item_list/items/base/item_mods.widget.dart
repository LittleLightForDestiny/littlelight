import 'package:bungie_api/enums/destiny_socket_category_style_enum.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_item_socket_state.dart';
import 'package:bungie_api/models/destiny_socket_category_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/destiny_item.stateful_widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

class ItemModsWidget extends DestinyItemStatefulWidget {
  final double iconSize;
  ItemModsWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key,
      String characterId,
      this.iconSize = 16})
      : super(item, definition, instanceInfo,
            key: key, characterId: characterId);

  @override
  ItemModsWidgetState createState() {
    return ItemModsWidgetState();
  }
}

class ItemModsWidgetState extends DestinyItemState<ItemModsWidget> {
  DestinySocketCategoryDefinition perksCatDefinition;
  List<DestinyItemSocketState> itemSockets;

  @override
  void initState() {
    super.initState();
    loadPerks();
  }

  loadPerks() async {
    var socketCategoryHashes =
        definition.sockets.socketCategories.map((s) => s.socketCategoryHash);
    var socketCategoryDefinitions = await widget.manifest
        .getDefinitions<DestinySocketCategoryDefinition>(socketCategoryHashes);
    perksCatDefinition = socketCategoryDefinitions.values.firstWhere((def) {
      return def.categoryStyle & DestinySocketCategoryStyle.Consumable ==
          DestinySocketCategoryStyle.Consumable;
    }, orElse: ()=>null);
    this.itemSockets = widget.profile.getItemSockets(item.itemInstanceId);
    if(!mounted){
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (perksCatDefinition == null) {
      return Container();
    }
    return buildMods(context, perksCatDefinition);
  }

  Widget buildMods(BuildContext context, DestinySocketCategoryDefinition def) {
    var socketCategory = definition.sockets.socketCategories.firstWhere(
        (s) => s.socketCategoryHash == def.hash,
        orElse: () => null);
    List<Widget> columns = [];
    socketCategory.socketIndexes.reversed.forEach((index) {
      if (isSocketVisible(index)) {
        columns.add(buildModIcon(context, itemSockets[index].plugHash));
        columns.add(Container(width: 1,));
      }
    });
    columns.removeLast();
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: columns.toList());
  }

  bool isSocketVisible(int index) {
    if (itemSockets != null) {
      return itemSockets[index].isVisible;
    }
    return true;
  }

  Widget buildModIcon(BuildContext context, int plugHash) {
    return Container(
      width: widget.iconSize,
      height: widget.iconSize,
      decoration: BoxDecoration(
        border: Border.all(width: .5, color:Colors.white),
        color: Colors.blueGrey.shade900),
      child: ManifestImageWidget<DestinyInventoryItemDefinition>(plugHash, placeholder: Container(),),
    );
  }
}
