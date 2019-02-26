import 'dart:async';

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_socket_category_definition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:bungie_api/enums/destiny_socket_category_style_enum.dart';

class ShareImageWidget extends StatelessWidget {
  final AdvancedNetworkImage backgroundImage;
  final AdvancedNetworkImage iconImage;
  final DestinyInventoryItemDefinition definition;
  final Map<int, DestinySocketCategoryDefinition> socketCategoryDefinitions;
  final Map<int, DestinyInventoryItemDefinition> plugItemDefinitions;

  ShareImageWidget(
      {Key key,
      this.backgroundImage,
      this.iconImage,
      this.definition,
      this.socketCategoryDefinitions, 
      this.plugItemDefinitions})
      : super(key: key);

  static Future<ShareImageWidget> builder(
      DestinyInventoryItemDefinition definition) async {
    ManifestService manifest = ManifestService();
    var backgroundImage =
        await loadImage(BungieApiService.url(definition.screenshot));
    var iconImage = await loadImage(
        BungieApiService.url(definition.displayProperties.icon));
    var socketCategoryHashes =
        definition.sockets.socketCategories.map((s) => s.socketCategoryHash);
    var socketCategoryDefinitions = await manifest
        .getDefinitions<DestinySocketCategoryDefinition>(socketCategoryHashes);

    var modHashes = [];
    definition.sockets.socketEntries.forEach((s){
      modHashes.addAll(s.reusablePlugItems.map((r)=>r.plugItemHash));
      modHashes.add(s.singleInitialItemHash);
    });

    var plugItemDefinitions = await manifest
        .getDefinitions<DestinyInventoryItemDefinition>(socketCategoryHashes);

    return ShareImageWidget(
      backgroundImage: backgroundImage,
      iconImage: iconImage,
      definition: definition,
      socketCategoryDefinitions: socketCategoryDefinitions,
      plugItemDefinitions: plugItemDefinitions,
    );
  }

  static Future<AdvancedNetworkImage> loadImage(String url) {
    var completer = Completer<AdvancedNetworkImage>();
    AdvancedNetworkImage image;
    image = AdvancedNetworkImage(url, loadedCallback: () {
      completer.complete(image);
    }, loadFailedCallback: () {
      completer.completeError(image);
    });
    image.load(image);
    if (completer.isCompleted) return Future.value(image);
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1920,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[buildHeader(context)]));
  }

  buildHeader(BuildContext context) {
    return Container(
        width: 1920,
        height: 1080,
        color: Colors.red,
        child: Stack(
          children: <Widget>[
            Positioned.fill(child: buildHeaderBackground(context)),
            buildItemInfo(context)
          ],
        ));
  }

  Widget buildHeaderBackground(BuildContext context) {
    return Image(
      image: backgroundImage,
      fit: BoxFit.none,
    );
  }

  Widget buildItemInfo(BuildContext context) {
    return Positioned(
        left: 148,
        top: 114,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            buildMainItemInfo(context),
            Container(height: 40),
            buildDescription(context),
            Container(height: 40),
            buildPerks(context)
          ],
        ));
  }

  Widget buildMainItemInfo(BuildContext context) {
    return Row(
      children: <Widget>[
        buildItemIcon(context),
        Container(
          width: 24,
        ),
        buildNameAndType(context)
      ],
    );
  }

  Widget buildItemIcon(BuildContext context) {
    return Container(
        height: 90,
        width: 90,
        decoration:
            BoxDecoration(border: Border.all(width: 3, color: Colors.white)),
        child: Image(
          image: iconImage,
          fit: BoxFit.cover,
        ));
  }

  Widget buildNameAndType(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          definition.displayProperties.name.toUpperCase(),
          style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
        ),
        Text(
          definition.itemTypeDisplayName.toUpperCase(),
          style: TextStyle(
              color: Colors.white.withOpacity(.6),
              fontSize: 36,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget buildDescription(BuildContext context) {
    return Container(
        width: 730,
        child: Text(
          definition.displayProperties.description,
          style: TextStyle(
              fontSize: 20,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w300),
        ));
  }

  Widget buildPerks(BuildContext context) {
    var perksCatDefinition = socketCategoryDefinitions.values.firstWhere((def) {
      return def.categoryStyle & DestinySocketCategoryStyle.Reusable ==
          DestinySocketCategoryStyle.Reusable;
    }, orElse: () => null);
    if (perksCatDefinition == null) return Container();
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        modifiersLabel(context, perksCatDefinition),
        Container(height: 16),
        buildPerksGrid(context, perksCatDefinition)
      ],
    );
  }

  Widget modifiersLabel(
      BuildContext context, DestinySocketCategoryDefinition def) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          def.displayProperties.name,
          style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(.6)),
        ),
        Container(
          height: 8,
        ),
        Container(
          height: 3,
          width: 730,
          color: Colors.white.withOpacity(.6),
        )
      ],
    );
  }

  Widget buildPerksGrid(
      BuildContext context, DestinySocketCategoryDefinition def) {
    var socketCategory = definition.sockets.socketCategories.firstWhere(
        (s) => s.socketCategoryHash == def.hash,
        orElse: () => null);
    List<Widget> columns = socketCategory.socketIndexes
        .expand((index) => [
              buildPerkColumn(context, index),
              Container(
                width: 2,
                color: Colors.white.withOpacity(.6),
                margin: EdgeInsets.symmetric(horizontal: 12),
              )
            ])
        .toList();
    columns.removeLast();
    return IntrinsicHeight(child:Container(width:730, child:Stack(
      children:[
        Positioned.fill(
          child:
        Image.asset('assets/imgs/perks_grid.png', repeat: ImageRepeat.repeat, alignment:Alignment(-.5, 0) ,)
        ),
        Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: columns.toList())
      ])));
      
  }

  Widget buildPerkColumn(BuildContext context, int socketIndex) {
    return Container(width: 72, height: 72, margin:EdgeInsets.all(4), color:Colors.blue);
  }
}
