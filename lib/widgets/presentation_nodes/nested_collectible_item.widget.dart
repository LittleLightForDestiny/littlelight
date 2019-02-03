import 'package:bungie_api/models/destiny_collectible_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:little_light/screens/item_detail.screen.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';

class NestedCollectibleItemWidget extends StatefulWidget {
  final ManifestService manifest = new ManifestService();
  final ProfileService profile = new ProfileService();
  final AuthService auth = new AuthService();
  final int hash;
  NestedCollectibleItemWidget({Key key, this.hash}) : super(key: key);

  @override
  State<NestedCollectibleItemWidget> createState() {
    return new NestedCollectibleItemWidgetState();
  }
}

class NestedCollectibleItemWidgetState
    extends State<NestedCollectibleItemWidget> {
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
        opacity: this.unlocked ? 1 : .4,
        child: AspectRatio(
            aspectRatio: 1,
            child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 1)),
                child: Stack(children: [
                  buildIcon(context),
                  FlatButton(
                    child: Container(),
                    onPressed: () async {
                      DestinyInventoryItemDefinition itemDef = await widget
                          .manifest
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
                ]))));
  }

  Widget buildIcon(BuildContext context) {
    if(definition?.displayProperties?.icon == null) return Container();
    return CachedNetworkImage(
        imageUrl: BungieApiService.url(definition.displayProperties.icon));
  }

  bool get unlocked {
    if (!widget.auth.isLogged) return true;
    if (definition == null) return false;
    return widget.profile.isCollectibleUnlocked(widget.hash, definition.scope);
  }
}
