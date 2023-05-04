import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/shared/widgets/containers/persistent_collapsible_container.dart';
import 'package:little_light/shared/widgets/inventory_item/duplicated_item.widget.dart';
import 'package:little_light/shared/widgets/inventory_item/interactive_item_wrapper.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/sliver_section.dart';

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
    return LayoutBuilder(builder: (context, constraints) {
      final perRow = (constraints.maxWidth / DuplicatedItemWidget.expectedSize.width).floor();
      return MultiSectionScrollView(
        [
          FixedHeightScrollSection(
            DuplicatedItemWidget.expectedSize.height,
            itemsPerRow: perRow,
            itemCount: items.length,
            itemBuilder: (_, index) => InteractiveItemWrapper(
              DuplicatedItemWidget(items[index]),
              item: items[index],
              itemMargin: 1,
            ),
          ),
        ],
        shrinkWrap: true,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
      );
    });
  }
}
