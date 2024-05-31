import 'package:bungie_api/models/destiny_collectible_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/widgets/loading/default_loading_shimmer.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

class LoadoutBackgroundItemWidget extends StatelessWidget {
  final int collectibleHash;
  const LoadoutBackgroundItemWidget(this.collectibleHash, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: buildEmblemBackground(context),
      decoration: BoxDecoration(
          border: Border.all(
        color: context.theme.onSurfaceLayers.layer2,
        width: 1,
      )),
    );
  }

  buildEmblemBackground(BuildContext context) {
    final collectible = context.definition<DestinyCollectibleDefinition>(collectibleHash);
    final definition = context.definition<DestinyInventoryItemDefinition>(collectible?.itemHash);
    if (definition == null) return const DefaultLoadingShimmer();
    String? url = definition.secondarySpecial;
    if (url == null) return const DefaultLoadingShimmer();
    return Stack(children: [
      Positioned.fill(
          child: QueuedNetworkImage.fromBungie(
        definition.secondarySpecial,
        alignment: Alignment.centerLeft,
        fadeInDuration: const Duration(milliseconds: 300),
        fit: BoxFit.cover,
        placeholder: const DefaultLoadingShimmer(),
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
