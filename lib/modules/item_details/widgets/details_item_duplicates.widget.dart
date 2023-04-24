import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/shared/widgets/containers/persistent_collapsible_container.dart';
import 'package:little_light/shared/widgets/inventory_item/duplicated_item.widget.dart';
import 'package:little_light/shared/widgets/inventory_item/interactive_item_wrapper.dart';

typedef OnItemAction = void Function(DestinyItemInfo);

class DetailsItemDuplicatesWidget extends StatelessWidget {
  final List<DestinyItemInfo> items;
  final OnItemAction? onItemTap;
  final OnItemAction? onItemHold;

  const DetailsItemDuplicatesWidget(this.items, {Key? key, this.onItemTap, this.onItemHold}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(4),
        child: PersistentCollapsibleContainer(
          title: Text("Duplicates".translate(context).toUpperCase()),
          persistenceID: 'item duplicates',
          content: buildContent(context),
        ));
  }

  Widget buildContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4),
      height: DuplicatedItemWidget.expectedSize.height,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: items
              .map(
                (e) => Container(
                  width: DuplicatedItemWidget.expectedSize.width,
                  margin: EdgeInsets.only(right: 4),
                  child: InteractiveItemWrapper(DuplicatedItemWidget(e), item: e),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
