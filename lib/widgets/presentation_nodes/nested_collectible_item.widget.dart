import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/widgets/presentation_nodes/collectible_item.widget.dart';

class NestedCollectibleItemWidget extends CollectibleItemWidget {
  NestedCollectibleItemWidget(
      {Key key, int hash, Map<int, List<ItemWithOwner>> itemsByHash})
      : super(key: key, itemsByHash: itemsByHash, hash: hash);

  @override
  CollectibleItemWidgetState createState() {
    return new NestedCollectibleItemWidgetState();
  }
}

class NestedCollectibleItemWidgetState extends CollectibleItemWidgetState {
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
                  Positioned.fill(child:buildIcon(context)),
                  Positioned(right: 4, bottom: 4, child: buildItemCount()),
                  Positioned.fill(child: buildSelectedBorder(context),),
                  buildButton(context)
                ]))));
  }

  Widget buildIcon(BuildContext context) {
    if (definition?.displayProperties?.icon == null) return Container();
    return QueuedNetworkImage(
        imageUrl: BungieApiService.url(definition.displayProperties.icon));
  }


  bool get unlocked {
    if (!widget.auth.isLogged) return true;
    if (definition == null) return false;
    return widget.profile.isCollectibleUnlocked(widget.hash, definition.scope);
  }
}
