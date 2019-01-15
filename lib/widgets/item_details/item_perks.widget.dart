import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_item_socket_category_definition.dart';
import 'package:bungie_api/models/destiny_item_socket_entry_definition.dart';
import 'package:bungie_api/models/destiny_item_socket_state.dart';
import 'package:bungie_api/models/destiny_socket_type_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/enums/definition_table_names.enum.dart';
import 'package:little_light/widgets/common/destiny_item.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

class ItemPerksWidget extends DestinyItemWidget {
  ItemPerksWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key})
      : super(item, definition, instanceInfo, key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          HeaderWidget(
              child: Container(
            alignment: Alignment.centerLeft,
            child: ManifestText(
              DefinitionTableNames.destinySocketCategoryDefinition,
              category.socketCategoryHash,
              uppercase: true,
              textAlign: TextAlign.left,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          )),
          Container(padding: EdgeInsets.all(8), child: perkColumns(context))
        ],
      ),
    );
  }

  Widget perkColumns(BuildContext context) {
    return Flex(
        direction: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: socketEntries
            .map((socket) => Flexible(child:plugItems(context, socket)))
            .toList());
  }

  Widget plugItems(
      BuildContext context, DestinyItemSocketEntryDefinition socket) {
    return Column(
        children: socket.reusablePlugItems.map((plugItem) {
      return ManifestImageWidget(
          DefinitionTableNames.destinyInventoryItemDefinition,
          plugItem.plugItemHash);
    }).toList());
  }

  List<DestinyItemSocketState> get instanceSockets =>
      profile.getItemSockets(item.itemInstanceId);

  List<DestinyItemSocketEntryDefinition> get socketEntries {
    return category.socketIndexes.map((index) {
      return definition.sockets.socketEntries[index];
    }).where((entry)=>entry.defaultVisible).toList();
  }

  DestinyItemSocketCategoryDefinition get category {
    return definition.sockets.socketCategories[0];
  }
}
