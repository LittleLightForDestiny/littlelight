import 'package:bungie_api/models/destiny_collectible_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:little_light/screens/item_detail.screen.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';

class CollectibleItemWidget extends StatefulWidget {
  final ManifestService manifest = new ManifestService();
  final ProfileService profile = new ProfileService();
  final AuthService auth = new AuthService();
  final int hash;
  CollectibleItemWidget({Key key, this.hash}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CollectibleItemWidgetState();
  }
}

class CollectibleItemWidgetState extends State<CollectibleItemWidget> {
  DestinyCollectibleDefinition _definition;
  DestinyCollectibleDefinition get definition {
    return widget.manifest.getDefinitionFromCache<DestinyCollectibleDefinition>(
            widget.hash) ??
        _definition;
  }

  @override
  void initState() {
    super.initState();
    loadDefinition();
  }

  loadDefinition() async {
    if (definition == null) {
      _definition = await widget.manifest
          .getDefinition<DestinyCollectibleDefinition>(widget.hash);
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
        opacity: unlocked ? 1 : .4,
        child: Container(
            margin: EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade600, width: 1),
                gradient: LinearGradient(
                    begin: Alignment(0, 0),
                    end: Alignment(1, 2),
                    colors: [
                      Colors.white.withOpacity(.05),
                      Colors.white.withOpacity(.1),
                      Colors.white.withOpacity(.03),
                      Colors.white.withOpacity(.1)
                    ])),
            child: Stack(children: [
              Row(
                children: <Widget>[
                  AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey.shade300, width: 1)),
                          margin: EdgeInsets.all(4),
                          child: buildIcon(context))),
                  buildTitle(context, definition),
                ],
              ),
              FlatButton(
                child: Container(),
                onPressed: () async {
                  DestinyInventoryItemDefinition itemDef = await widget.manifest
                      .getDefinition<DestinyInventoryItemDefinition>(
                          definition.itemHash);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemDetailScreen(
                          null, itemDef, null,
                          characterId: null),
                    ),
                  );
                },
              )
            ])));
  }

  Widget buildIcon(BuildContext context) {
    if (definition?.displayProperties?.icon == null) return Container();
    return CachedNetworkImage(
      imageUrl: BungieApiService.url(definition.displayProperties.icon),
    );
  }

  buildTitle(BuildContext context, DestinyCollectibleDefinition definition) {
    return Expanded(
        child: Container(padding: EdgeInsets.all(8), child: buildTitleText()));
  }

  buildTitleText() {
    if (definition == null) return Container();
    return Text(definition.displayProperties.name,
        softWrap: true,
        style: TextStyle(
            color: Colors.grey.shade300, fontWeight: FontWeight.bold));
  }

  bool get unlocked {
    if (!widget.auth.isLogged) return true;
    if (definition == null) return false;
    return widget.profile.isCollectibleUnlocked(widget.hash, definition.scope);
  }
}
