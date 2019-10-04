import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_socket_category_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/item_sockets/base_socket_details.widget.dart';
import 'package:little_light/widgets/item_sockets/item_socket.controller.dart';
import 'package:little_light/widgets/item_stats/item_details_socket_item_stats.widget.dart';

class ItemDetailsSocketDetailsWidget extends BaseSocketDetailsWidget {
  final ItemSocketController controller;
  ItemDetailsSocketDetailsWidget(
      {DestinyItemComponent item,
      DestinyItemSocketCategoryDefinition category,
      DestinyInventoryItemDefinition parentDefinition,
      this.controller})
      : super(item: item, definition: parentDefinition, category:category);

  @override
  ItemDetailsSocketDetailsWidgetState createState() =>
      ItemDetailsSocketDetailsWidgetState();
}

class ItemDetailsSocketDetailsWidgetState
    extends BaseSocketDetailsWidgetState<ItemDetailsSocketDetailsWidget> {
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
    bool isSameCategory = widget?.category?.socketIndexes?.contains(controller.selectedSocketIndex) ?? true;
    if (controller.selectedPlugHash != null && isSameCategory) {
      _definition = await widget.manifest
          .getDefinition<DestinyInventoryItemDefinition>(
              controller.selectedPlugHash);
      return super.loadDefinitions();
    } else {
      _definition = null;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_definition == null) return Container();
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          buildHeader(context),
          Container(
              padding: EdgeInsets.all(16),
              color: Colors.black,
              child: buildContent(context))
        ]));
  }

  buildHeader(BuildContext context) {
    Color bgColor = DestinyData.perkColor;
    return Container(
      color: bgColor,
      padding: EdgeInsets.all(8),
      child: Row(children: [
        Container(
            width: 48,
            height: 48,
            child: QueuedNetworkImage(
                imageUrl:
                    BungieApiService.url(definition?.displayProperties?.icon))),
        Container(width: 8),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              definition?.displayProperties?.name?.toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(definition?.itemTypeDisplayName,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300))
          ],
        ))
      ]),
    );
  }

  buildContent(BuildContext context) {
    var showStats = (definition?.investmentStats?.length ?? 0) > 0;
    Iterable<Widget> items = [
      Text(definition?.displayProperties?.description,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300)),
      !showStats
          ? null
          : ItemDetailSocketItemStatsWidget(
              plugDefinition: definition,
              definition: itemDefinition,
              item: item,
              socketController: widget.controller,
            )
    ];
    items = items.where((i) => i != null).expand((w) => [
          w,
          Container(
              margin: EdgeInsets.symmetric(vertical: 16),
              color: Colors.white,
              height: 1)
        ]);
    items = items.take(items.length - 1);
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: items.toList());
  }
}
