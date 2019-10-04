import 'dart:math';

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_socket_category_definition.dart';
import 'package:bungie_api/models/destiny_socket_category_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/item_sockets/base_item_sockets.widget.dart';
import 'package:little_light/widgets/item_sockets/item_socket.controller.dart';

class DetailsItemModsWidget extends BaseItemSocketsWidget {
  DetailsItemModsWidget({
    Key key,
    DestinyItemComponent item,
    DestinyInventoryItemDefinition definition,
    DestinyItemSocketCategoryDefinition category,
    ItemSocketController controller,
  }) : super(
            key: key,
            item: item,
            definition: definition,
            category: category,
            controller: controller);

  @override
  State<StatefulWidget> createState() {
    return DetailsItemPerksWidgetState();
  }
}

class DetailsItemPerksWidgetState<T extends DetailsItemModsWidget>
    extends BaseItemSocketsWidgetState<T> {
  bool showDetails = false;

  @override
  Widget build(BuildContext context) {
    return super.build(context);
  }

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
    return Container();
    // return Row(
    //   children: <Widget>[
    //     TranslatedTextWidget(
    //       "Details",
    //       uppercase: true,
    //       style: TextStyle(fontWeight: FontWeight.bold),
    //     ),
    //     Container(
    //       width: 4,
    //     ),
    //     SmallerSwitch(
    //       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    //       value: showDetails,
    //       onChanged: (value) {
    //         showDetails = value;
    //         setState(() {});
    //       },
    //     )
    //   ],
    // );
  }

  @override
  Widget buildSockets(BuildContext context) {
    Iterable<Widget> children = category.socketIndexes
        .map((socketIndex) => buildSocketPlugs(context, socketIndex))
        .where((w) => w != null);
    var screenWidth = MediaQuery.of(context).size.width - 16;
    var dividerMargin = min(screenWidth / 50, 8.0);
    children = children.expand((w) => [
          w,
          Container(
              margin: EdgeInsets.symmetric(horizontal: dividerMargin),
              width: 2,
              color: Colors.white.withOpacity(.4))
        ]);
    children = children.take(children.length - 1);
    var mq = MediaQueryHelper(context);
    var largeScreen = mq.isDesktop || (mq.tabletOrBigger && mq.isLandscape);
    if (!largeScreen && showDetails) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: children.toList());
    }
    return IntrinsicHeight(
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: children.toList()));
  }

  @override
  Widget buildSocketPlugs(BuildContext context, int socketIndex) {
    var plugs = socketPlugHashes(socketIndex);
    var selectedPlugHash = controller.socketSelectedPlugHash(socketIndex);
    if (plugs.length == 0) return null;
    var mq = MediaQueryHelper(context);
    if (mq.isDesktop || (mq.tabletOrBigger && mq.isLandscape)) {
      return Expanded(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [buildPlugCategoryTitle(context, socketIndex)]
            .followedBy([buildPlug(context, socketIndex, selectedPlugHash)])
            .toList(),
      ));
    }
    if (showDetails) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [buildPlugCategoryTitle(context, socketIndex)]
            .followedBy(plugs.map((p) => buildPlug(context, socketIndex, p)))
            .toList(),
      );
    }
    var screenWidth = MediaQuery.of(context).size.width - 16;
    
    return Container(
        width: min(64, screenWidth / 8),
        child: buildPlug(context, socketIndex, selectedPlugHash),
        );
  }

  Widget buildPlugCategoryTitle(BuildContext context, int socketIndex) {
    var hashes = socketPlugHashes(socketIndex);
    var hash = hashes.first;

    Widget contents =
        DefinitionProviderWidget<DestinyInventoryItemDefinition>(hash, (def) {
      if ((def?.itemTypeDisplayName?.length ?? 0) <= 1) {
        return TranslatedTextWidget(
          "Other",
          uppercase: true,
          overflow: TextOverflow.fade,
          softWrap: false,
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      } else {
        return Text(
          def?.itemTypeDisplayName?.toUpperCase() ?? "",
          overflow: TextOverflow.fade,
          softWrap: false,
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      }
    });

    return Container(
        color: Colors.black,
        alignment: Alignment.center,
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.only(bottom: 8),
        child: contents);
  }

  @override
  Widget buildPlug(BuildContext context, int socketIndex, int plugItemHash) {
    var mq = MediaQueryHelper(context);
    if (mq.isDesktop || (mq.tabletOrBigger && mq.isLandscape) || showDetails) {
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
    Color bgColor =
        Color.lerp(DestinyData.perkColor, Colors.black, .7).withOpacity(.8);
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
            Container(
                width: 36,
                height: 36,
                child: ManifestImageWidget<DestinyInventoryItemDefinition>(
                    plugItemHash)),
            Container(width: 8),
            Expanded(
              child: ManifestText<DestinyInventoryItemDefinition>(plugItemHash),
            )
          ]),
          onPressed: () {
            controller.selectSocket(socketIndex, plugItemHash);
          },
        ));
  }

  Widget buildPlugIcon(
      BuildContext context, int socketIndex, int plugItemHash) {
    if (plugDefinitions == null) return Container();
    return Container(
        child: AspectRatio(
            aspectRatio: 1,
            child: FlatButton(
              padding: EdgeInsets.all(0),
              child: ManifestImageWidget<DestinyInventoryItemDefinition>(
                  plugItemHash),
              onPressed: () {
                controller.selectSocket(socketIndex, plugItemHash);
              },
            )));
  }
}
