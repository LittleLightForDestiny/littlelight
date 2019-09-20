import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_socket_category_definition.dart';
import 'package:bungie_api/models/destiny_socket_category_definition.dart';

import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/item_sockets/base_item_sockets.widget.dart';

class ScreenShotItemPerksWidget extends BaseItemSocketsWidget {
  final double pixelSize;
  ScreenShotItemPerksWidget({
    Key key,
    DestinyItemComponent item,
    DestinyInventoryItemDefinition definition,
    DestinyItemSocketCategoryDefinition category,
    this.pixelSize = 1,
  }) : super(key: key, item: item, definition: definition, category: category);

  @override
  State<StatefulWidget> createState() {
    return ScreenShotItemPerksWidgetState();
  }
}

class ScreenShotItemPerksWidgetState<T extends ScreenShotItemPerksWidget>
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
    return Stack(children: [
      Positioned.fill(
          child: Image.asset(
        "assets/imgs/perks_grid.png",
        repeat: ImageRepeat.repeat,
        alignment: Alignment.center,
        scale: 1/widget.pixelSize,
        
      )),
      IntrinsicHeight(
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: category.socketIndexes
                  .map((socketIndex) =>
                      buildSocketPlugs(context, socketIndex))
                  .expand((w) => [
                        w,
                        Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: widget.pixelSize * 12),
                            width: 2 * widget.pixelSize,
                            color: Colors.white.withOpacity(.4))
                      ])
                  .toList()))
    ]);
  }

  @override
  Widget buildSocketPlugs(BuildContext context, int socketIndex) {
    var plugs = socketPlugHashes(socketIndex);
    return Container(
        width: 80 * widget.pixelSize,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: plugs.map((p) => buildPlug(context, socketIndex, p)).toList(),
        ));
  }

  @override
  Widget buildPlug(BuildContext context, int socketIndex, int plugItemHash) {
    if (plugDefinitions == null) return Container();
    var plugDef = plugDefinitions[plugItemHash];
    bool intrinsic = plugDef?.plug?.plugCategoryIdentifier == "intrinsics";
    int equippedHash = socketEquippedPlugHash(socketIndex);
    bool isEquipped = equippedHash == plugItemHash;
    return Container(
        margin: EdgeInsets.only(bottom: 8 * widget.pixelSize),
        padding: intrinsic
            ? EdgeInsets.all(0)
            : EdgeInsets.all(10 * widget.pixelSize),
        decoration: intrinsic
            ? null
            : BoxDecoration(
                color: isEquipped ? DestinyData.perkColor : Colors.transparent, 
                borderRadius: BorderRadius.circular(50)),
        child: AspectRatio(
            aspectRatio: 1,
            child: QueuedNetworkImage(
                imageUrl:
                    BungieApiService.url(plugDef?.displayProperties?.icon))));
  }
}
