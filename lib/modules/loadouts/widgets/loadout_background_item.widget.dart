// @dart=2.9

import 'package:bungie_api/models/destiny_collectible_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/widgets/loading/default_loading_shimmer.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

class LoadoutBackgroundItemWidget extends StatefulWidget {
  final int hash;
  LoadoutBackgroundItemWidget({Key key, this.hash}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LoadoutBackgroundItemWidgetState();
  }
}

class LoadoutBackgroundItemWidgetState extends State<LoadoutBackgroundItemWidget> with ManifestConsumer {
  DestinyInventoryItemDefinition definition;

  @override
  void initState() {
    super.initState();
    loadDefinitions();
  }

  void loadDefinitions() async {
    var collectible = await manifest.getDefinition<DestinyCollectibleDefinition>(widget.hash);
    definition = await manifest.getDefinition<DestinyInventoryItemDefinition>(collectible?.itemHash);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: buildEmblemBackground(context),
      decoration: BoxDecoration(
          border: Border.all(
        color: LittleLightTheme.of(context).onSurfaceLayers.layer2,
        width: 1,
      )),
    );
  }

  buildEmblemBackground(BuildContext context) {
    if (definition == null) return DefaultLoadingShimmer();
    ;
    String url = BungieApiService.url(definition.secondarySpecial);
    if (url == null) return DefaultLoadingShimmer();
    ;
    return Stack(children: [
      Positioned.fill(
          child: QueuedNetworkImage(
        alignment: Alignment.centerLeft,
        fadeInDuration: Duration(milliseconds: 300),
        imageUrl: "$url",
        fit: BoxFit.cover,
        placeholder: DefaultLoadingShimmer(),
      )),
      Positioned.fill(
          child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context, definition.hash);
                },
              )))
    ]);
  }
}
