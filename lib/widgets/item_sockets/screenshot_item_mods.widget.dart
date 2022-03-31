// @dart=2.9

import 'package:bungie_api/enums/destiny_energy_type.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_socket_category_definition.dart';
import 'package:bungie_api/models/destiny_socket_category_definition.dart';
import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

import 'package:little_light/widgets/item_sockets/base_item_sockets.widget.dart';
import 'package:little_light/widgets/item_sockets/item_socket.controller.dart';

class ScreenShotItemModsWidget extends BaseItemSocketsWidget {
  final double pixelSize;
  ScreenShotItemModsWidget({
    Key key,
    DestinyItemComponent item,
    DestinyInventoryItemDefinition definition,
    DestinyItemSocketCategoryDefinition category,
    ItemSocketController controller,
    this.pixelSize = 1,
  }) : super(key: key, category: category, controller: controller);

  @override
  State<StatefulWidget> createState() {
    return ScreenShotItemModsWidgetState();
  }
}

const _sectionId = "screenshot_item_mods";

class ScreenShotItemModsWidgetState<T extends ScreenShotItemModsWidget> extends BaseItemSocketsWidgetState<T> {
  @override
  String get sectionId => _sectionId;

  @override
  bool get visible => true;

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
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(.7),
          ),
        ),
        Container(
            margin: EdgeInsets.only(top: 2 * widget.pixelSize, bottom: 16 * widget.pixelSize),
            color: Theme.of(context).colorScheme.onSurface.withOpacity(.7),
            height: 3 * widget.pixelSize)
      ],
    );
  }

  @override
  Widget buildSockets(BuildContext context) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: category.socketIndexes
            .map((socketIndex) => buildSocketPlugs(context, socketIndex))
            .where((w) => w != null)
            .expand((w) => [
                  w,
                  Container(
                    width: 10 * widget.pixelSize,
                  )
                ])
            .toList());
  }

  @override
  Widget buildSocketPlugs(BuildContext context, int socketIndex) {
    var plugHash = socketSelectedPlugHash(socketIndex);
    if (plugHash == null) return null;

    return Container(
      height: 96 * widget.pixelSize,
      width: 96 * widget.pixelSize,
      child: buildPlug(context, socketIndex, plugHash),
    );
  }

  @override
  Widget buildPlug(BuildContext context, int socketIndex, int plugItemHash) {
    if (plugDefinitions == null) return Container();
    final def = controller.plugDefinitions[plugItemHash];
    final energyType = def?.plug?.energyCost?.energyType ?? DestinyEnergyType.Any;
    final energyCost = def?.plug?.energyCost?.energyCost ?? 0;
    final canEquip = controller?.canEquip(socketIndex, plugItemHash);
    final emptyModHash = 1835369552;
    return Material(
        child: InkWell(
            onTap: () {
              controller.selectSocket(socketIndex, plugItemHash);
            },
            child: Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400, width: 3 * widget.pixelSize)),
                child: Stack(children: [
                  ManifestImageWidget<DestinyInventoryItemDefinition>(
                    plugItemHash,
                    key: Key("plug_$plugItemHash"),
                    noIconPlaceholder: ManifestImageWidget<DestinyInventoryItemDefinition>(emptyModHash),
                  ),
                  energyType == DestinyEnergyType.Any
                      ? Container()
                      : Positioned.fill(
                          child: ManifestImageWidget<DestinyStatDefinition>(
                              DestinyData.getEnergyTypeCostHash(energyType))),
                  energyCost == 0
                      ? Container()
                      : Positioned(
                          top: 8 * widget.pixelSize,
                          right: 8 * widget.pixelSize,
                          child: Text(
                            "$energyCost",
                            style: TextStyle(fontSize: 20 * widget.pixelSize),
                          )),
                  canEquip
                      ? Container()
                      : Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(.5),
                          ),
                        )
                ]))));
  }
}
