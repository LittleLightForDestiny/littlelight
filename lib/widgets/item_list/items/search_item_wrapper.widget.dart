import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/widgets/item_list/items/inventory_item_wrapper.widget.dart';

class SearchItemWrapperWidget extends InventoryItemWrapperWidget {
  SearchItemWrapperWidget(DestinyItemComponent item, int bucketHash,
      {String characterId, Key key})
      : super(item, bucketHash, characterId: characterId, key:key);

  @override
  InventoryItemWrapperWidgetState<SearchItemWrapperWidget> createState() {
    return SearchItemWrapperWidgetState();
  }
}

class SearchItemWrapperWidgetState<T extends SearchItemWrapperWidget>
    extends InventoryItemWrapperWidgetState<SearchItemWrapperWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.blueGrey.shade600)),
        child:Stack(children: [
      Positioned.fill(child: buildItem(context)),
      Positioned(right: 2, top: 2, child: buildCharacterIcon(context)),
      buildTapHandler(context)
    ]));
  }

  Widget buildCharacterIcon(BuildContext context) {
    Widget icon;
    if (widget.characterId != null) {
      var character = widget.profile.getCharacter(widget.characterId);
      icon = CachedNetworkImage(
          imageUrl: BungieApiService.url(character.emblemPath));
    } else {
      if (widget.item.bucketHash == InventoryBucket.general) {
        icon = Image.asset("assets/imgs/vault-icon.jpg");
      } else {
        icon = Image.asset("assets/imgs/inventory-icon.jpg");
      }
    }
    return Container(
      width: 26,
      height: 26,
      child:icon
    );
  }
  @override
  void onLongPress(context) {
  }
}
