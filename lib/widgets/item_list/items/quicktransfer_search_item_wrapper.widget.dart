// @dart=2.9

import 'package:flutter/material.dart';
import 'package:little_light/pages/item_details/item_details.page_route.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/widgets/item_list/items/search_item_wrapper.widget.dart';

class QuickTransferSearchItemWrapper extends SearchItemWrapperWidget {
  QuickTransferSearchItemWrapper(ItemWithOwner item, int bucketHash, {String characterId, Key key})
      : super(item, bucketHash, characterId: characterId, key: key);

  @override
  QuickTransferSearchItemWrapperWidgetWidgetState createState() {
    return QuickTransferSearchItemWrapperWidgetWidgetState();
  }
}

class QuickTransferSearchItemWrapperWidgetWidgetState
    extends SearchItemWrapperWidgetState<QuickTransferSearchItemWrapper> {
  @override
  void onTap(context) {
    Navigator.of(context).pop(widget.item);
  }

  @override
  void onLongPress(context) {
    Navigator.push(
      context,
      ItemDetailsPageRoute.viewOnly(
        item: widget.item,
        heroKey: uniqueId,
      ),
    );
  }
}
