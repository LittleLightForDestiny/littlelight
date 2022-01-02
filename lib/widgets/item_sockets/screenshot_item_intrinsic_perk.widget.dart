import 'package:bungie_api/enums/tier_type.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_socket_category_definition.dart';
import 'package:bungie_api/models/destiny_socket_category_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/item_sockets/base_item_sockets.widget.dart';
import 'package:little_light/widgets/item_sockets/item_socket.controller.dart';

class ScreenShotItemIntrinsicPerkWidget extends BaseItemSocketsWidget {
  final double pixelSize;
  ScreenShotItemIntrinsicPerkWidget({
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
    return ScreenShotItemIntrinsicPerkWidgetState();
  }
}

const _sectionId = "screenshot_intrinsic_perks";

class ScreenShotItemIntrinsicPerkWidgetState<
        T extends ScreenShotItemIntrinsicPerkWidget>
    extends BaseItemSocketsWidgetState<T> {
  @override
  String get sectionId => _sectionId;

  @override
  bool get visible => true;

  @override
  Widget build(BuildContext context) {
    if (category == null) return Container();
    Iterable<int> plugs = category.socketIndexes
        .map((socketIndex) => socketPlugHashes(socketIndex).length)
        .where((l) => l > 0);
    if (plugs.length == 0) return Container();
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
            margin: EdgeInsets.only(
                top: 2 * widget.pixelSize, bottom: 16 * widget.pixelSize),
            color: Theme.of(context).colorScheme.onSurface.withOpacity(.7),
            height: 3 * widget.pixelSize)
      ],
    );
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
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          width: 80 * widget.pixelSize,
          child: buildPlug(context, socketIndex, plugHash)),
      Container(width: 20 * widget.pixelSize),
      Expanded(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ManifestText<DestinyInventoryItemDefinition>(
            plugHash,
            uppercase: true,
            style: TextStyle(
                fontSize: 22 * widget.pixelSize, fontWeight: FontWeight.bold),
          ),
          Container(height: 10 * widget.pixelSize),
          ManifestText<DestinyInventoryItemDefinition>(
            plugHash,
            textExtractor: (def) => def.displayProperties.description,
            softWrap: true,
            style: TextStyle(
                fontSize: 22 * widget.pixelSize, fontWeight: FontWeight.w300),
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
        BorderSide(color: borderColor, width: 2 * widget.pixelSize);

    return Container(
        key: Key("plug_${socketIndex}_$plugItemHash"),
        padding: EdgeInsets.all(0),
        margin: EdgeInsets.only(bottom: 16 * widget.pixelSize),
        child: AspectRatio(
            aspectRatio: 1,
            child: MaterialButton(
              shape: intrinsic && !isExotic
                  ? RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4 * widget.pixelSize),
                      side: borderSide)
                  : CircleBorder(side: borderSide),
              padding: EdgeInsets.all(intrinsic ? 0 : 8 * widget.pixelSize),
              color: bgColor,
              child: ManifestImageWidget<DestinyInventoryItemDefinition>(
                  plugItemHash),
              onPressed: () {
                controller.selectSocket(socketIndex, plugItemHash);
              },
            )));
  }
}
