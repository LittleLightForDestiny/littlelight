import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/screens/item_detail.screen.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/widgets/item_list/items/search_item_wrapper.widget.dart';

class QuickTransferSearchItemWrapper extends SearchItemWrapperWidget {
  QuickTransferSearchItemWrapper(DestinyItemComponent item, int bucketHash,
      {String characterId, Key key})
      : super(item, bucketHash, characterId: characterId, key:key);

  @override
  QuickTransferSearchItemWrapperWidgetWidgetState createState() {
    return QuickTransferSearchItemWrapperWidgetWidgetState();
  }
}

class QuickTransferSearchItemWrapperWidgetWidgetState
    extends SearchItemWrapperWidgetState<QuickTransferSearchItemWrapper> {
  @override
  
  @override
  void onTap(context) {
    Navigator.of(context).pop(ItemWithOwner(widget.item, widget.characterId));
  }

  @override
  void onLongPress(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailScreen(
              item:widget.item,
              definition:definition,
              instanceInfo:instanceInfo,
              characterId: widget.characterId,
              uniqueId: uniqueId,
              hideItemManagement: true,
            ),
      ));
  }
}
