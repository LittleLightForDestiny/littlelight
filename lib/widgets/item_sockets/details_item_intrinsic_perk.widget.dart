

import 'package:bungie_api/enums/tier_type.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_socket_category_definition.dart';
import 'package:bungie_api/models/destiny_socket_category_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';

import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/item_sockets/base_item_sockets.widget.dart';
import 'package:little_light/widgets/item_sockets/item_socket.controller.dart';

class DetailsItemIntrinsicPerkWidget extends BaseItemSocketsWidget {
  DetailsItemIntrinsicPerkWidget({
    Key key,
    DestinyItemComponent item,
    DestinyInventoryItemDefinition definition,
    DestinyItemSocketCategoryDefinition category,
    ItemSocketController controller,
  }) : super(
            key: key,
            item: item,
            definition: definition,
            category: category,
            controller: controller);

  @override
  State<StatefulWidget> createState() {
    return DetailsItemArmorExoticPerkWidgetState();
  }
}

class DetailsItemArmorExoticPerkWidgetState<T extends DetailsItemIntrinsicPerkWidget>
    extends BaseItemSocketsWidgetState<T> {
  bool showDetails = false;

  @override
  Widget build(BuildContext context) {
     if (category == null) return Container();
     Iterable<int> plugs = category.socketIndexes
        .map((socketIndex) => socketPlugHashes(socketIndex).length)
        .where((l) => l > 0);
    if(plugs.length == 0) return Container();
    return super.build(context);
  }

  Widget buildHeader(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(bottom: 8),
        child: HeaderWidget(
            child: Container(
                alignment: Alignment.centerLeft,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ManifestText<DestinySocketCategoryDefinition>(
                        category.socketCategoryHash,
                        uppercase: true,
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ]))));
  }


  @override
  Widget buildSockets(BuildContext context) {
    Iterable<Widget> children = category.socketIndexes
        .map((socketIndex) => buildSocketPlugs(context, socketIndex))
        .where((w) => w != null);
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: children.toList());
  }

  @override
  Widget buildSocketPlugs(BuildContext context, int socketIndex) {
    var plugs = socketPlugHashes(socketIndex);
    var plugHash = socketSelectedPlugHash(socketIndex);
    if ((plugs?.length ?? 0) == 0) return null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Container(
          width: 64,
          child: buildPlug(context, socketIndex, plugHash)),
      Container(width: 16),
      Expanded(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ManifestText<DestinyInventoryItemDefinition>(
            plugHash,
            uppercase: true,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Container(height:8),
          ManifestText<DestinyInventoryItemDefinition>(
            plugHash,
            textExtractor: (def) => def.displayProperties.description,
            softWrap: true,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
          ),
        ],
      ))
    ]);
  }

  
  @override
  Widget buildPlug(BuildContext context, int socketIndex, int plugItemHash) {
    if (plugDefinitions == null) return Container();
    var plugDef = plugDefinitions[plugItemHash];
    bool intrinsic = plugDef?.plug?.plugCategoryIdentifier == "intrinsics";
    int equippedHash = socketEquippedPlugHash(socketIndex);
    bool isEquipped = equippedHash == plugItemHash;
    bool isExotic = definition.inventory.tierType == TierType.Exotic;
    bool isSelectedOnSocket =
        plugItemHash == controller.socketSelectedPlugHash(socketIndex);
    bool isSelected = plugItemHash == controller.selectedPlugHash;
    Color bgColor = Colors.transparent;
    Color borderColor = Colors.grey.shade300.withOpacity(.5);
    if (isEquipped && !intrinsic) {
      bgColor = DestinyData.perkColor.withOpacity(.5);
    }
    if (isSelectedOnSocket && !intrinsic) {
      bgColor = DestinyData.perkColor;
      borderColor = Colors.grey.shade300;
    }

    if (intrinsic && !isSelected) {
      borderColor = Colors.transparent;
    }

    BorderSide borderSide =
        BorderSide(color: borderColor, width: 2);

    return Container(
        key: Key("plug_${socketIndex}_$plugItemHash"),
        padding: EdgeInsets.all(0),
        child: AspectRatio(
            aspectRatio: 1,
            child: MaterialButton(
              shape: intrinsic && !isExotic
                  ? RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: borderSide)
                  : CircleBorder(side: borderSide),
              padding: EdgeInsets.all(0),
              color: bgColor,
              child: ManifestImageWidget<DestinyInventoryItemDefinition>(
                  plugItemHash),
              onPressed: () {
                controller.selectSocket(socketIndex, plugItemHash);
              },
            )));
  }
}
