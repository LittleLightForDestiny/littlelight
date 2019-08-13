import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/screens/item_detail.screen.dart';
import 'package:little_light/widgets/item_list/items/search_item_wrapper.widget.dart';

class LoadoutSearchItemWrapperWidget extends SearchItemWrapperWidget {
  LoadoutSearchItemWrapperWidget(DestinyItemComponent item, int bucketHash,
      {String characterId, Key key})
      : super(item, bucketHash, characterId: characterId, key:key);

  @override
  LoadoutSearchItemWrapperWidgetWidgetState createState() {
    return LoadoutSearchItemWrapperWidgetWidgetState();
  }
}

class LoadoutSearchItemWrapperWidgetWidgetState
    extends SearchItemWrapperWidgetState<LoadoutSearchItemWrapperWidget> {
  @override
  
  @override
  void onTap(context) {
    Navigator.of(context).pop(widget.item);
  }

  @override
  void onLongPress(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailScreen(
              widget.item,
              definition,
              instanceInfo,
              characterId: widget.characterId,
              uniqueId: uniqueId,
              hideItemManagement: true,
            ),
      ),
    );
  }
}
