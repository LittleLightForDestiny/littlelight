import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_socket_category_definition.dart';
import 'package:bungie_api/models/destiny_socket_category_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/wish_list.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/wishlist_badge.widget.dart';
import 'package:little_light/widgets/item_sockets/base_item_sockets.widget.dart';
import 'package:little_light/widgets/item_sockets/item_socket.controller.dart';
import 'package:little_light/widgets/item_sockets/plug_wishlist_tag_icons.mixin.dart';
import 'package:little_light/widgets/item_sockets/selectable_perk.widget.dart';

class ScreenShotItemPerksWidget extends BaseItemSocketsWidget {
  final double pixelSize;
  ScreenShotItemPerksWidget({
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

class ScreenShotItemPerksWidgetState<T extends ScreenShotItemPerksWidget>
    extends BaseItemSocketsWidgetState<T> with PlugWishlistTagIconsMixin {
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
    children = children.expand((w) => [
          w,
          Container(
              margin: EdgeInsets.symmetric(horizontal: widget.pixelSize * 12),
              width: 2 * widget.pixelSize,
              color: Colors.white.withOpacity(.4))
        ]);
    children = children.take(children.length - 1);
    return Stack(children: [
      Positioned.fill(
          child: Image.asset(
        "assets/imgs/perks_grid.png",
        repeat: ImageRepeat.repeat,
        alignment: Alignment.center,
        scale: 1 / widget.pixelSize,
      )),
      IntrinsicHeight(
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: children.toList()))
    ]);
  }

  @override
  Widget buildSocketPlugs(BuildContext context, int socketIndex) {
    var plugs = socketPlugHashes(socketIndex);
    if (plugs.length == 0) return null;
    return Container(
        width: 80 * widget.pixelSize,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children:
              plugs.map((p) => buildPlug(context, socketIndex, p)).toList(),
        ));
  }

  @override
  Set<int> socketPlugHashes(int socketIndex) {
    if (controller.reusablePlugs == null) {
      var isRandom = controller.randomizedPlugHashes(socketIndex).length > 0;
      if (isRandom) {
        return controller.bungieRollPlugHashes(socketIndex).followedBy(
            [controller.socketRandomizedSelectedPlugHash(socketIndex)]).toSet();
      }
    }
    return super.socketPlugHashes(socketIndex);
  }

  @override
  Widget buildPlug(BuildContext context, int socketIndex, int plugItemHash) {
    if (plugDefinitions == null) return Container();
    var plugDef = plugDefinitions[plugItemHash];
    int equippedHash = socketEquippedPlugHash(socketIndex);
    bool isEquipped = equippedHash == plugItemHash;
    bool isSelectedOnSocket =
        plugItemHash == controller.socketSelectedPlugHash(socketIndex);
    bool isSelected = plugItemHash == controller.selectedPlugHash;

    return SelectablePerkWidget(
      selected: isSelected,
      selectedOnSocket: isSelectedOnSocket,
      itemDefinition: widget.definition,
      plugHash: plugItemHash,
      plugDefinition: plugDef,
      equipped: isEquipped,
      key: Key("$plugItemHash $isSelected $isSelectedOnSocket"),
      onTap: () {
        controller.selectSocket(socketIndex, plugItemHash);
      },
    );
  }

  @override
  Widget buildWishlistIcon(BuildContext context, WishlistTag tag) {
    return WishlistBadgeWidget(
        tags: [tag].toSet(), size: 24 * widget.pixelSize);
  }
}
