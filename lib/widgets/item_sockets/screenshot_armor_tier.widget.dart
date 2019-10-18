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

class ScreenShotArmorTierWidget extends BaseItemSocketsWidget {
  final double pixelSize;
  ScreenShotArmorTierWidget({
    Key key,
    DestinyItemComponent item,
    DestinyInventoryItemDefinition definition,
    DestinyItemSocketCategoryDefinition category,
    ItemSocketController controller,
    this.pixelSize = 1,
  }) : super(
            key: key,
            item: item,
            definition: definition,
            category: category,
            controller: controller);

  @override
  State<StatefulWidget> createState() {
    return ScreenShotItemPerksWidgetState();
  }
}

class ScreenShotItemPerksWidgetState<T extends ScreenShotArmorTierWidget>
    extends BaseItemSocketsWidgetState<T> {
  @override
  Widget build(BuildContext context) {
    if (category == null) return Container();
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        buildHeader(context),
        buildSockets(context),
      ],
    );
  }

  Widget buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ManifestText<DestinySocketCategoryDefinition>(
          category.socketCategoryHash,
          style: TextStyle(
            fontSize: 24 * widget.pixelSize,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(.7),
          ),
        ),
        Container(
            margin: EdgeInsets.only(
                top: 2 * widget.pixelSize, bottom: 16 * widget.pixelSize),
            color: Colors.white.withOpacity(.7),
            height: 3 * widget.pixelSize)
      ],
    );
  }

  @override
  Widget buildSockets(BuildContext context) {
    Iterable<Widget> children = category.socketIndexes
        .map((socketIndex) => buildSocketPlugs(context, socketIndex))
        .where((w) => w != null);
    return Column(children: children.toList());
  }

  @override
  Widget buildSocketPlugs(BuildContext context, int socketIndex) {
    int equippedHash = socketEquippedPlugHash(socketIndex);
    return Container(
        width: widget.pixelSize * 520,
        child: buildPlug(context, socketIndex, equippedHash));
  }

  @override
  Widget buildPlug(BuildContext context, int socketIndex, int plugItemHash) {
    if (plugDefinitions == null) return Container();
    var plugDef = plugDefinitions[plugItemHash];
    var color = DestinyData.getEnergyTypeColor(
        plugDef?.plug?.energyCapacity?.energyType);
    var total = plugDef?.plug?.energyCapacity?.capacityValue;
    return Column(children:[
      Container(
        height: widget.pixelSize * 50,
        padding: EdgeInsets.symmetric(horizontal: widget.pixelSize * 10),
        color: color.withOpacity(.6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
                DestinyData.getEnergyTypeIcon(
                    plugDef?.plug?.energyCapacity?.energyType),
                color: DestinyData.getEnergyTypeLightColor(
        plugDef?.plug?.energyCapacity?.energyType),
                size: widget.pixelSize * 44),
            Container(
              width: widget.pixelSize * 8,
            ),
            Text(
              "$total",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: widget.pixelSize * 38),
            ),
            Container(
              width: widget.pixelSize * 16,
            ),
            TranslatedTextWidget(
              "Energy",
              uppercase: true,
              style: TextStyle(
                  fontWeight: FontWeight.w400, fontSize: widget.pixelSize * 22),
            )
          ],
        )),
        buildBars(context, plugItemHash)
        ]);
  }

  Widget buildBars(BuildContext context, int plugItemHash){
     if (plugDefinitions == null) return Container();
    var plugDef = plugDefinitions[plugItemHash];
    var total = plugDef?.plug?.energyCapacity?.capacityValue;
    var used = controller.usedEnergyWithoutFailedSocket;
    var requiredEnergy = controller.requiredEnergy;
    List<Widget> pieces = [];
    for(var i=0; i<10; i++){
      pieces.add(Expanded(child: buildEnergyPiece(context, i, total, used, requiredEnergy)));
    }
    return Row(children: pieces,);
  }

  Widget buildEnergyPiece(BuildContext context, int index, int total, int used, int requiredEnergy){
    if(index < total){
      Color color = index < requiredEnergy ? DestinyData.negativeFeedback.withOpacity(.8) : Colors.transparent;
      if(index < used){
        color = Colors.white;
      }
      return Container(
        height:30*widget.pixelSize,
        padding: EdgeInsets.all(2*widget.pixelSize),
        child: Container(decoration: BoxDecoration(border: Border.all(width:4*widget.pixelSize, color:Colors.white), color:color),),
      );
    }

    return Container(
        height:30*widget.pixelSize,
        padding: EdgeInsets.symmetric(horizontal:2*widget.pixelSize, vertical: 8*widget.pixelSize),
        child: Container(color: index < requiredEnergy ? DestinyData.negativeFeedback.withOpacity(.8) : Colors.black.withOpacity(.5),),
      );
  }
}
