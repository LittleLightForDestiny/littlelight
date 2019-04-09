import 'package:bungie_api/enums/destiny_socket_category_style_enum.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
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
  List<DestinyItemSocketState> itemSockets;

  @override
  void initState() {
    super.initState();
    if(widget.item != null){
      loadPerks();
    }
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
    this.itemSockets = widget.profile.getItemSockets(item.itemInstanceId);
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
    if(socketCategory == null || itemSockets == null) return Container();
    socketCategory.socketIndexes.forEach((index) {
      if (isSocketVisible(index)) {
        columns.add(buildPerkIcon(context, itemSockets[index].plugHash));
      }
    });
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: columns.toList());
  }

  bool isSocketVisible(int index) {
    if (itemSockets != null) {
      return itemSockets[index].isVisible;
    }
    return true;
  }

  Widget buildPerkIcon(BuildContext context, int plugHash) {
    return Container(
      width: widget.iconSize,
      height: widget.iconSize,
      child: ManifestImageWidget<DestinyInventoryItemDefinition>(plugHash, placeholder: Container(),),
    );
  }
}
