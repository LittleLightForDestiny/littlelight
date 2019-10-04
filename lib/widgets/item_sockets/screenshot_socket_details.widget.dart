import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/item_sockets/base_socket_details.widget.dart';
import 'package:little_light/widgets/item_sockets/item_socket.controller.dart';
import 'package:little_light/widgets/item_stats/screenshot_socket_item_stats.widget.dart';

class ScreenshotSocketDetailsWidget extends BaseSocketDetailsWidget {
  final ItemSocketController controller;
  final double pixelSize;
  ScreenshotSocketDetailsWidget(
      {DestinyItemComponent item,
      DestinyInventoryItemDefinition parentDefinition,
      this.controller,
      this.pixelSize})
      : super(item: item, definition: parentDefinition);

  @override
  _ScreenshotPerkDetailsWidgetState createState() =>
      _ScreenshotPerkDetailsWidgetState();
}

class _ScreenshotPerkDetailsWidgetState
    extends BaseSocketDetailsWidgetState<ScreenshotSocketDetailsWidget> {
  ItemSocketController get controller => widget.controller;
  DestinyInventoryItemDefinition _definition;
  DestinyInventoryItemDefinition get definition => _definition;
  DestinyInventoryItemDefinition get itemDefinition => widget.definition;

  @override
  void initState() {
    controller.addListener(socketChanged);
    super.initState();
  }

  void dispose() {
    controller.removeListener(socketChanged);
    super.dispose();
  }

  socketChanged() async {
    await this.loadDefinitions();
  }

  @override
  loadDefinitions() async {
    if (controller.selectedPlugHash != null) {
      _definition = await widget.manifest
          .getDefinition<DestinyInventoryItemDefinition>(
              controller.selectedPlugHash);
      return super.loadDefinitions();
    } else {
      _definition = null;
      if(mounted){
        setState((){});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_definition == null) return Container();
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: widget.pixelSize * 5,
            color: Colors.grey.shade400,
          ),
          Container(
              padding: EdgeInsets.all(16 * widget.pixelSize),
              color: Colors.black,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    definition?.displayProperties?.name?.toUpperCase(),
                    style: TextStyle(
                        fontSize: 30 * widget.pixelSize,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(definition?.itemTypeDisplayName,
                      style: TextStyle(
                          fontSize: 24 * widget.pixelSize,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w300))
                ],
              )),
          Container(
              padding: EdgeInsets.all(16 * widget.pixelSize),
              color: Colors.black.withOpacity(.7),
              child: buildContent(context))
        ]);
  }

  buildContent(BuildContext context) {
    var showStats = (definition?.investmentStats?.length ?? 0) > 0;
    Iterable<Widget> items = [
      Text(definition?.displayProperties?.description,
          style: TextStyle(
              fontSize: 24 * widget.pixelSize, fontWeight: FontWeight.w300)),
      !showStats
          ? null
          : ScreenShotSocketItemStatsWidget(
              plugDefinition: definition,
              definition: itemDefinition,
              item: item,
              pixelSize: widget.pixelSize,
              socketController: widget.controller,
            )
    ];
    items = items.where((i) => i != null).expand((w) => [
          w,
          Container(
              margin: EdgeInsets.symmetric(vertical: widget.pixelSize * 16),
              color: Colors.white,
              height: widget.pixelSize)
        ]);
    items = items.take(items.length - 1);
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: items.toList());
  }
}
