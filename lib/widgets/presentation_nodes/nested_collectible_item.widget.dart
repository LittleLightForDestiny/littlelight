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

class NestedCollectibleItemWidget extends StatelessWidget {
  final ManifestService manifest = new ManifestService();
  final ProfileService profile = new ProfileService();
  final AuthService auth = new AuthService();
  final int hash;
  NestedCollectibleItemWidget({Key key, this.hash}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Opacity(
        opacity: this.unlocked ? 1 : .4,
        child: DefinitionProviderWidget<DestinyCollectibleDefinition>(hash,
            (definition) {
          return AspectRatio(
              aspectRatio: 1,
              child: Container(
                  decoration: BoxDecoration(
                      border:
                          Border.all(color: Colors.grey.shade300, width: 1)),
                  child: Stack(children: [
                    CachedNetworkImage(
                        imageUrl: BungieApiService.url(
                            definition.displayProperties.icon)),
                    FlatButton(
                      child: Container(),
                      onPressed: () async {
                        DestinyInventoryItemDefinition itemDef = await manifest
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
        }));
  }

  bool get unlocked {
    if (!auth.isLogged) return true;
    return profile.isCollectibleUnlocked(hash);
  }
}
