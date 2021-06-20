import 'dart:math';

import 'package:bungie_api/enums/destiny_energy_type.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_socket_category_definition.dart';
import 'package:bungie_api/models/destiny_socket_category_definition.dart';
import 'package:bungie_api/models/destiny_stat_definition.dart';
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

const _sectionId = "item_mods";

class DetailsItemPerksWidgetState<T extends DetailsItemModsWidget>
    extends BaseItemSocketsWidgetState<T> {
  bool showDetails = false;

  String get sectionId => "${_sectionId}_${category.socketCategoryHash}";

  Widget buildHeader(BuildContext context) {
    return getHeader(ManifestText<DestinySocketCategoryDefinition>(
      category.socketCategoryHash,
      uppercase: true,
      textAlign: TextAlign.left,
      style: TextStyle(fontWeight: FontWeight.bold),
    ));
  }

  Widget buildDetailsSwitch(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSockets(BuildContext context) {
    Iterable<Widget> children = category.socketIndexes
        .map((socketIndex) => buildSocketPlugs(context, socketIndex))
        .where((w) => w != null);
    var mq = MediaQueryHelper(context);
    var largeScreen = mq.isDesktop || (mq.tabletOrBigger && mq.isLandscape);
    var screenWidth = MediaQuery.of(context).size.width - 16;
    var dividerMargin = min(screenWidth / 50, 8.0);
    if (children.length > 0) {
      children = children.expand((w) => [
            w,
            largeScreen
                ? Container(
                    margin: EdgeInsets.symmetric(horizontal: dividerMargin),
                    width: 2,
                    color: Colors.white.withOpacity(.4))
                : Container(width: dividerMargin)
          ]);
      children = children.take(children.length - 1);
    }
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
        children: [buildPlugCategoryTitle(context, socketIndex)].followedBy(
            [buildPlug(context, socketIndex, selectedPlugHash)]).toList(),
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
        key: Key("item_mod_$plugItemHash"),
        padding: EdgeInsets.all(0),
        margin: EdgeInsets.only(bottom: 8),
        child: MaterialButton(
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
    var def = controller.plugDefinitions[plugItemHash];
    var energyType = def?.plug?.energyCost?.energyType ?? DestinyEnergyType.Any;
    var energyCost = def?.plug?.energyCost?.energyCost ?? 0;
    var canEquip = controller?.canEquip(socketIndex, plugItemHash);
    var selectedSocketIndex = controller.selectedSocketIndex;
    bool selected = selectedSocketIndex == socketIndex;
    return Container(
        key: Key("item_mod_$plugItemHash"),
        child: AspectRatio(
            aspectRatio: 1,
            child: MaterialButton(
              padding: EdgeInsets.all(0),
              shape: ContinuousRectangleBorder(
                  side: BorderSide(
                      color: selected
                          ? Colors.white
                          : Colors.grey.shade300.withOpacity(.5),
                      width: 1.5)),
              child: Stack(children: [
                ManifestImageWidget<DestinyInventoryItemDefinition>(
                    plugItemHash),
                energyType == DestinyEnergyType.Any
                    ? Container()
                    : Positioned.fill(
                        child: ManifestImageWidget<DestinyStatDefinition>(
                            DestinyData.getEnergyTypeCostHash(energyType))),
                energyCost == 0
                    ? Container()
                    : Positioned(
                        top: 4,
                        right: 4,
                        child: Text(
                          "$energyCost",
                          style: TextStyle(fontSize: 12),
                        )),
                canEquip
                    ? Container()
                    : Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(.5),
                        ),
                      )
              ]),
              onPressed: () {
                controller.selectSocket(socketIndex, plugItemHash);
              },
            )));
  }
}
