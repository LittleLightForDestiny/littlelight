import 'package:bungie_api/enums/tier_type_enum.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_socket_category_definition.dart';
import 'package:bungie_api/models/destiny_socket_category_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/flutter/smaller_switch.dart';
import 'package:little_light/widgets/item_sockets/base_item_sockets.widget.dart';
import 'package:little_light/widgets/item_sockets/item_socket.controller.dart';

class DetailsItemPerksWidget extends BaseItemSocketsWidget {
  final double pixelSize;
  DetailsItemPerksWidget({
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

class ScreenShotItemPerksWidgetState<T extends DetailsItemPerksWidget>
    extends BaseItemSocketsWidgetState<T> {
  bool showDetails = false;

  Widget buildHeader(BuildContext context) {
    bool isLandscape = MediaQueryHelper(context).isLandscape;
    return Container(
        padding: EdgeInsets.only(bottom: 16),
        child: HeaderWidget(
            child: Container(
                alignment: Alignment.centerLeft,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ManifestText<DestinySocketCategoryDefinition>(
                        category.socketCategoryHash,
                        uppercase: true,
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      isLandscape ? Container() : buildDetailsSwitch(context)
                    ]))));
  }

  Widget buildDetailsSwitch(BuildContext context) {
    return Row(
      children: <Widget>[
        TranslatedTextWidget(
          "Details",
          uppercase: true,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Container(
          width: 4,
        ),
        SmallerSwitch(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          value: showDetails,
          onChanged: (value) {
            showDetails = value;
            setState(() {});
          },
        )
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
              margin: EdgeInsets.symmetric(horizontal: 8),
              width: 2,
              color: Colors.white.withOpacity(.4))
        ]);
    children = children.take(children.length - 1);
    return Stack(children: [
      Positioned.fill(
          child: Image.asset(
        "assets/imgs/perks_grid.png",
        repeat: ImageRepeat.repeat,
        alignment: Alignment.center,
        scale: 1,
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
    return Expanded(
        child: Container(
            child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [buildPlugCategoryTitle(context, socketIndex)].followedBy(plugs.map((p) => buildPlug(context, socketIndex, p))).toList(),
    )));
  }

  Widget buildPlugCategoryTitle(BuildContext context, int socketIndex){
    var hashes = socketPlugHashes(socketIndex);
    var hash = hashes.first;
    var def = plugDefinitions[hash];
    Widget contents;
    if ((def?.itemTypeDisplayName?.length ?? 0) <= 1) {
      contents = TranslatedTextWidget(
        "Other",
        uppercase: true,
        style: TextStyle(fontWeight: FontWeight.bold),
      );
    }else{
      contents = Text(
        def?.itemTypeDisplayName?.toUpperCase() ?? "",
        style: TextStyle(fontWeight: FontWeight.bold),
      );
    }
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      padding: EdgeInsets.all(8),
      margin:EdgeInsets.only(bottom:8),
      child: contents
    );
  }

  @override
  Widget buildPlug(BuildContext context, int socketIndex, int plugItemHash) {
    var mq = MediaQueryHelper(context);
    if (mq.isDesktop || (mq.tabletOrBigger && mq.isLandscape)) {
      return buildPlugListItem(context, socketIndex, plugItemHash);
    }
    return buildPlugIcon(context, socketIndex, plugItemHash);
  }

  Widget buildPlugListItem(
      BuildContext context, int socketIndex, int plugItemHash) {
    int equippedHash = socketEquippedPlugHash(socketIndex);
    bool isEquipped = equippedHash == plugItemHash;
    bool isSelectedOnSocket =
        plugItemHash == controller.socketSelectedPlugHash(socketIndex);
    Color bgColor = Color.lerp(DestinyData.perkColor, Colors.black, .7).withOpacity(.8);
    Color borderColor = Colors.grey.shade300.withOpacity(.5);
    if (isEquipped) {
      bgColor = DestinyData.perkColor.withOpacity(.5);
    }
    if (isSelectedOnSocket) {
      bgColor = DestinyData.perkColor;
      borderColor = Colors.grey.shade300;
    }

    BorderSide borderSide = BorderSide(color: borderColor, width: 2);

    return Container(
        padding: EdgeInsets.all(0),
        margin: EdgeInsets.only(bottom: 8),
        child: FlatButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4), side: borderSide),
          padding: EdgeInsets.all(8),
          color: bgColor,
          child: Row(children: [
            Container(width:36, height:36, child:ManifestImageWidget<DestinyInventoryItemDefinition>(plugItemHash)),
            Container(width:8),
            Expanded(child: ManifestText<DestinyInventoryItemDefinition>(plugItemHash),)
          ]),
          onPressed: () {
            controller.selectSocket(socketIndex, plugItemHash);
          },
        ));
  }

  Widget buildPlugIcon(
      BuildContext context, int socketIndex, int plugItemHash) {
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

    BorderSide borderSide = BorderSide(color: borderColor, width: 2);

    return Container(
        padding: EdgeInsets.all(0),
        margin: EdgeInsets.only(bottom: 16),
        child: AspectRatio(
            aspectRatio: 1,
            child: FlatButton(
              shape: intrinsic && !isExotic
                  ? RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4), side: borderSide)
                  : CircleBorder(side: borderSide),
              padding: EdgeInsets.all(intrinsic ? 0 : 8),
              color: bgColor,
              child: ManifestImageWidget<DestinyInventoryItemDefinition>(
                  plugItemHash),
              onPressed: () {
                print(plugItemHash);
                controller.selectSocket(socketIndex, plugItemHash);
              },
            )));
  }
}
