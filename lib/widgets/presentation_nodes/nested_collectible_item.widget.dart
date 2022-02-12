//@dart=2.12

import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/widgets/presentation_nodes/collectible_item.widget.dart';

class NestedCollectibleItemWidget extends CollectibleItemWidget {
  NestedCollectibleItemWidget({Key? key, required int hash}) : super(key: key, hash: hash);

  @override
  CollectibleItemWidgetState createState() {
    return NestedCollectibleItemWidgetState();
  }
}

class NestedCollectibleItemWidgetState extends CollectibleItemWidgetState with ProfileConsumer {
  @override
  Widget build(BuildContext context) {
    return Opacity(
        opacity: this.unlocked ? 1 : .4,
        child: AspectRatio(
            aspectRatio: 1,
            child: Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300, width: 1)),
                child: Stack(children: [
                  Positioned.fill(child: buildIcon(context)),
                  Positioned(right: 4, bottom: 4, child: buildItemCount()),
                  Positioned.fill(
                    child: buildSelectedBorder(context),
                  ),
                  buildButton(context)
                ]))));
  }

  Widget buildIcon(BuildContext context) {
    final iconURL = BungieApiService.url(definition?.displayProperties?.icon);
    if (iconURL == null) return Container();
    return QueuedNetworkImage(imageUrl: iconURL);
  }

  bool get unlocked {
    final scope = definition?.scope;
    if (scope == null) return false;
    return profile.isCollectibleUnlocked(widget.hash, scope);
  }
}
