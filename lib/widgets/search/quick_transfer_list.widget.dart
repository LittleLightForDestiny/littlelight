import 'package:flutter/material.dart';
import 'package:little_light/widgets/item_list/items/quicktransfer_search_item_wrapper.widget.dart';
import 'package:little_light/widgets/search/search.controller.dart';
import 'package:little_light/widgets/search/search_list.widget.dart';

class QuickTransferListWidget extends SearchListWidget {
  QuickTransferListWidget({Key key, SearchController controller})
      : super(key: key, controller: controller);

  @override
  _QuickTransferListWidgetState createState() =>
      _QuickTransferListWidgetState();
}

class _QuickTransferListWidgetState
    extends SearchListWidgetState<QuickTransferListWidget> {
  @override
  Widget getItem(BuildContext context, int index) {
    var item = widget.controller.filtered[index];
    return QuickTransferSearchItemWrapper(item.item, null,
        characterId: item.ownerId,
        key: Key("item_${item.item.itemInstanceId}_${item.item.itemHash}"));
  }
}
