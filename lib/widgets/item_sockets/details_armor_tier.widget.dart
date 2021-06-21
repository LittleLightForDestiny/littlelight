import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_socket_category_definition.dart';
import 'package:bungie_api/models/destiny_socket_category_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/item_sockets/base_item_sockets.widget.dart';
import 'package:little_light/widgets/item_sockets/item_socket.controller.dart';

class DetailsArmorTierWidget extends BaseItemSocketsWidget {
  DetailsArmorTierWidget({
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
    return DetailsArmorTierWidgetState();
  }
}

const _sectionId = "armor_tier";

class DetailsArmorTierWidgetState<T extends DetailsArmorTierWidget>
    extends BaseItemSocketsWidgetState<T> {
  bool showDetails = false;

  @override
  String get sectionId => "${_sectionId}_${category.socketCategoryHash}";

  @override
  Widget build(BuildContext context) {
    return super.build(context);
  }

  Widget buildHeader(BuildContext context) {
    return getHeader(
      ManifestText<DestinySocketCategoryDefinition>(
        category.socketCategoryHash,
        uppercase: true,
        textAlign: TextAlign.left,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget buildSockets(BuildContext context) {
    Iterable<Widget> children = category.socketIndexes
        .map((socketIndex) => buildSocketPlugs(context, socketIndex))
        .where((w) => w != null);
    return Container(
        alignment: Alignment.center,
        child: Container(
            constraints: BoxConstraints.tightFor(width: 600),
            child: Column(children: children.toList())));
  }

  @override
  Widget buildSocketPlugs(BuildContext context, int socketIndex) {
    int equippedHash = socketEquippedPlugHash(socketIndex);
    return Container(child: buildPlug(context, socketIndex, equippedHash));
  }

  @override
  Widget buildPlug(BuildContext context, int socketIndex, int plugItemHash) {
    if (plugDefinitions == null) return Container();
    var plugDef = plugDefinitions[plugItemHash];
    var color = DestinyData.getEnergyTypeColor(
        plugDef?.plug?.energyCapacity?.energyType);
    var total = plugDef?.plug?.energyCapacity?.capacityValue;
    return Column(children: [
      Container(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: 8),
          color: color.withOpacity(.6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                  DestinyData.getEnergyTypeIcon(
                      plugDef?.plug?.energyCapacity?.energyType),
                  color: DestinyData.getEnergyTypeLightColor(
                      plugDef?.plug?.energyCapacity?.energyType),
                  size: 20),
              Container(
                width: 4,
              ),
              Text(
                "$total",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              Container(
                width: 4,
              ),
              TranslatedTextWidget(
                "Energy",
                uppercase: true,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              )
            ],
          )),
      buildBars(context, plugItemHash)
    ]);
  }

  Widget buildBars(BuildContext context, int plugItemHash) {
    if (plugDefinitions == null) return Container();
    var plugDef = plugDefinitions[plugItemHash];
    var total = plugDef?.plug?.energyCapacity?.capacityValue;
    var used = controller.usedEnergyWithoutFailedSocket;
    var requiredEnergy = controller.requiredEnergy;
    List<Widget> pieces = [];
    for (var i = 0; i < 10; i++) {
      pieces.add(Expanded(
          child: buildEnergyPiece(context, i, total, used, requiredEnergy)));
    }
    return Container(
        padding: EdgeInsets.all(8),
        color: Colors.blueGrey.shade600,
        child: Row(
          children: pieces,
        ));
  }

  Widget buildEnergyPiece(BuildContext context, int index, int total, int used,
      int requiredEnergy) {
    if (index < total) {
      Color color = index < requiredEnergy
          ? DestinyData.negativeFeedback.withOpacity(.8)
          : Colors.transparent;
      if (index < used) {
        color = Colors.white;
      }
      return Container(
        height: 16,
        padding: EdgeInsets.all(2),
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(width: 2, color: Colors.white), color: color),
        ),
      );
    }

    return Container(
      height: 16,
      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 5),
      child: Container(
        color: index < requiredEnergy
            ? DestinyData.negativeFeedback.withOpacity(.8)
            : Colors.black.withOpacity(.5),
      ),
    );
  }
}
