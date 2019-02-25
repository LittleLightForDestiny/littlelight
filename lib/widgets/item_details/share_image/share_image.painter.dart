import 'dart:async';

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';

class ShareImageWidget extends StatelessWidget {
  final AdvancedNetworkImage backgroundImage;
  final AdvancedNetworkImage iconImage;
  final DestinyInventoryItemDefinition definition;

  static Future<ShareImageWidget> builder(
      DestinyInventoryItemDefinition definition) async {
    var backgroundImage =
        await loadImage(BungieApiService.url(definition.screenshot));
    var iconImage = await loadImage(
        BungieApiService.url(definition.displayProperties.icon));
    return ShareImageWidget(
      backgroundImage: backgroundImage,
      iconImage: iconImage,
      definition: definition,
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
    return completer.future;
  }

  const ShareImageWidget({Key key, this.backgroundImage, this.iconImage, this.definition})
      : super(key: key);

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
          children: <Widget>[buildMainItemInfo(context),
          Container(height:40),
          buildDescription(context)
          ],
        ));
  }

  Widget buildMainItemInfo(BuildContext context) {
    return Row(
      children: <Widget>[
        buildItemIcon(context),
        Container(width: 24,),
        buildNameAndType(context)
      ],
    );
  }

  Widget buildItemIcon(BuildContext context) {
    return Container(
        height:90,
        width: 90,
        decoration: BoxDecoration(border: Border.all(width: 3, color:Colors.white)),
        child:Image(image: iconImage, fit: BoxFit.cover,)
      );
  }

  Widget buildNameAndType(BuildContext context){
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
      Text(definition.displayProperties.name.toUpperCase(),
      style: TextStyle(
        fontSize: 50,
        fontWeight: FontWeight.bold
      ),),
      Text(definition.itemTypeDisplayName.toUpperCase(),
      style: TextStyle(
        color: Colors.white.withOpacity(.6),
        fontSize: 36,
        fontWeight: FontWeight.w600
      ),),
    ],);
  }
  Widget buildDescription(BuildContext context){
    return Container(
      width:730,
      child:Text(definition.displayProperties.description, style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic, fontWeight: FontWeight.w300),));
  }
}
