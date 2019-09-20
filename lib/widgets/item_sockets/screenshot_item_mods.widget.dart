import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_socket_category_definition.dart';
import 'package:bungie_api/models/destiny_socket_category_definition.dart';

import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/item_sockets/base_item_sockets.widget.dart';

class ScreenShotItemModsWidget extends BaseItemSocketsWidget {
  final double pixelSize;
  ScreenShotItemModsWidget({
    Key key,
    DestinyItemComponent item,
    DestinyInventoryItemDefinition definition,
    DestinyItemSocketCategoryDefinition category,
    this.pixelSize = 1,
  }) : super(key: key, item: item, definition: definition, category: category);

  @override
  State<StatefulWidget> createState() {
    return ScreenShotItemModsWidgetState();
  }
}

class ScreenShotItemModsWidgetState<T extends ScreenShotItemModsWidget>
    extends BaseItemSocketsWidgetState<T> {
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
    return IntrinsicHeight(
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: category.socketIndexes
                .map(
                    (socketIndex) => buildSocketPlugs(context, socketIndex))
                .expand((w) => [
                      w,
                      Container(
                          width: 10 * widget.pixelSize,
                          )
                    ])
                .toList()));
  }

  @override
  Widget buildSocketPlugs(BuildContext context, int socketIndex) {
    var plugHash = socketEquippedPlugHash(socketIndex);
    return Container(
        width: 96 * widget.pixelSize,
        child: buildPlug(context, socketIndex, plugHash),
        );
  }

  @override
  Widget buildPlug(BuildContext context, int socketIndex, int plugItemHash) {
    if (plugDefinitions == null) return Container();
    var plugDef = plugDefinitions[plugItemHash];
    return FlatButton(
      padding: EdgeInsets.all(0),
      onPressed: (){
        print(plugDef?.displayProperties?.icon);
      },
      child:Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400, width:3*widget.pixelSize)),
        child: AspectRatio(
            aspectRatio: 1,
            child: QueuedNetworkImage(
                imageUrl:
                    BungieApiService.url(plugDef?.displayProperties?.icon)))));
  }
}
