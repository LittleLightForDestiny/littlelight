// @dart=2.9

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:little_light/pages/item_details/item_details.page_route.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateful_item.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/item_details/section_header.widget.dart';
import 'package:little_light/widgets/item_list/items/base/base_item_instance.widget.dart';

class ItemDetailDuplicatesWidget extends BaseDestinyStatefulItemWidget {
  final List<ItemWithOwner> duplicates;

  ItemDetailDuplicatesWidget(
      ItemWithOwner item, DestinyInventoryItemDefinition definition, DestinyItemInstanceComponent instanceInfo,
      {Key key, this.duplicates})
      : super(
            item: item?.item, characterId: item?.ownerId, definition: definition, instanceInfo: instanceInfo, key: key);

  @override
  State<StatefulWidget> createState() {
    return ItemDetailDuplicatesWidgetState();
  }
}

const _sectionId = "duplicated_items";

class ItemDetailDuplicatesWidgetState extends BaseDestinyItemState<ItemDetailDuplicatesWidget>
    with VisibleSectionMixin, ProfileConsumer {
  @override
  String get sectionId => _sectionId;

  @override
  Widget build(BuildContext context) {
    if ((widget.duplicates?.length ?? 0) < 1) {
      return Container();
    }
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          getHeader(
            TranslatedTextWidget(
              "Duplicates",
              uppercase: true,
              textAlign: TextAlign.left,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          visible ? Container(height: 8) : Container(),
          visible ? buildDuplicatedItems(context) : Container()
        ],
      ),
    );
  }

  Widget buildDuplicatedItems(BuildContext context) {
    var isTablet = MediaQueryHelper(context).tabletOrBigger;
    return StaggeredGrid.count(
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        crossAxisCount: 10,
        children: widget.duplicates
            .map((item) => StaggeredGridTile.extent(
                  crossAxisCellCount: isTablet ? 2 : 5,
                  mainAxisExtent: 132,
                  child: buildItemInstance(item, context),
                ))
            .toList());
  }

  Widget buildItemInstance(ItemWithOwner item, BuildContext context) {
    var instance = profile.getInstanceInfo(item.item.itemInstanceId);
    return Stack(key: Key("duplicate_${item.item.itemInstanceId}_${item.ownerId}"), children: <Widget>[
      BaseItemInstanceWidget(item.item, definition, instance, characterId: item.ownerId, uniqueId: null),
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => instanceTap(context, item),
        ),
      )
    ]);
  }

  void instanceTap(
    BuildContext context,
    ItemWithOwner item,
  ) {
    final route = ItemDetailsPageRoute(
      item: item,
    );
    if (this.instanceInfo != null) {
      Navigator.pushReplacement(context, route);
    } else {
      Navigator.push(context, route);
    }
  }
}
