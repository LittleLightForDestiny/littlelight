import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_socket_category_definition.dart';
import 'package:bungie_api/models/destiny_item_socket_state.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/wish_list.dart';
import 'package:little_light/services/littlelight/wishlists.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateful_item.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/common/wishlist_badge.widget.dart';
import 'package:little_light/widgets/item_sockets/item_socket.controller.dart';

class BaseItemSocketsWidget extends BaseDestinyStatefulItemWidget {
  final ProfileService profile = ProfileService();
  final ManifestService manifest = ManifestService();
  final ItemSocketController controller;
  final DestinyItemSocketCategoryDefinition category;

  final double iconSize;

  BaseItemSocketsWidget(
      {Key key,
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      this.category,
      this.iconSize = 72,
      this.controller})
      : super(key: key, item: item, definition: definition);

  @override
  State<StatefulWidget> createState() {
    return BaseItemSocketsWidgetState();
  }
}

class BaseItemSocketsWidgetState<T extends BaseItemSocketsWidget>
    extends BaseDestinyItemState<T> {
  
  List<DestinyItemSocketState> _socketStates;
  List<DestinyItemSocketState> get socketStates => _socketStates;
  Map<int, DestinyInventoryItemDefinition> get plugDefinitions =>
      controller?.plugDefinitions;
  DestinyItemSocketCategoryDefinition get category => widget.category;
  ItemSocketController _controller;
  ItemSocketController get controller {
    if (widget.controller != null) {
      return widget.controller;
    }
    if (_controller == null) {
      _controller = ItemSocketController(item: item, definition: definition);
    }
    return _controller;
  }

  @override
  initState() {
    super.initState();
    _socketStates = widget.profile.getItemSockets(item?.itemInstanceId);
    initController();
  }

  void initController() {
    controller.addListener(update);
  }

  @override
  dispose() {
    super.dispose();
    controller.removeListener(update);
  }

  update() {
    setState(() {});
  }

  Set<int> socketPlugHashes(int socketIndex) {
    return controller.socketPlugHashes(socketIndex) ?? Set();
  }

  int socketEquippedPlugHash(int socketIndex) {
    return controller.socketEquippedPlugHash(socketIndex);
  }

  int socketSelectedPlugHash(int socketIndex) {
    return controller.socketSelectedPlugHash(socketIndex);
  }

  @override
  Widget build(BuildContext context) {
    if (category == null) return Container();
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        buildHeader(context),
        buildErrorMessage(context),
        buildSockets(context),
      ],
    );
  }

  Widget buildHeader(BuildContext context) {
    return Container();
  }

  Widget buildErrorMessage(BuildContext context) {
    if (item?.itemInstanceId != null && socketStates == null) {
      return Container(
          margin: EdgeInsets.only(bottom: 16),
          child: TranslatedTextWidget(
            "Bungie.net API isn't returning sockets correctly on items right now, so you are seeing the default definition instead of the perks and mods you have on your items.",
            style: TextStyle(color: Colors.red.shade300),
          ));
    }
    return Container();
  }

  Widget buildSockets(BuildContext context) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: category.socketIndexes
            .map((socketIndex) => buildSocketPlugs(context, socketIndex))
            .toList());
  }

  Widget buildSocketPlugs(BuildContext context, int socketIndex) {
    var plugs = socketPlugHashes(socketIndex);
    return Container(
        width: widget.iconSize,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children:
              plugs.map((p) => buildPlug(context, socketIndex, p)).toList(),
        ));
  }

  Widget buildPlug(BuildContext context, int socketIndex, int plugItemHash) {
    return Container(
        child: AspectRatio(
            aspectRatio: 1,
            child: ManifestImageWidget<DestinyInventoryItemDefinition>(
              plugItemHash,
            )));
  }


  List<Widget> wishlistIcons(BuildContext context, int plugItemHash) {
    var tags = WishlistsService().getPerkTags(definition.hash, plugItemHash);
    if (tags == null) return [];
    List<Widget> items = [];
    if (tags.contains(WishlistTag.PVE)) {
      items.add(buildWishlistIcon(context, WishlistTag.PVE));
    }else{
      items.add(Container());
    }
    if (tags.contains(WishlistTag.PVP)) {
      items.add(buildWishlistIcon(context, WishlistTag.PVP));
    }
    return items;
  }

  buildWishlistIcon(BuildContext context, WishlistTag tag){
    return WishlistBadgeWidget(tags:[tag].toSet(), size:16);
  }

  Widget buildWishlistTagIcons(int plugItemHash) {
    var icons = wishlistIcons(context, plugItemHash);
    if ((icons?.length ?? 0) > 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: icons);
    }
    return Container();
  }
}
