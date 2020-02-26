import 'dart:async';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/inventory/inventory.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/services/selection/selection.service.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/inventory_tabs/multiselect_management_block.widget.dart';
import 'package:little_light/widgets/item_list/items/base/base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/quick_select_item_wrapper.widget.dart';
import 'package:little_light/widgets/item_list/items/search_item_wrapper.widget.dart';
import 'package:uuid/uuid.dart';

class SelectedItemsWidget extends StatefulWidget {
  final service = SelectionService();

  SelectedItemsWidget({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SelectedItemsWidgetState();
  }
}

class SelectedItemsWidgetState extends State<SelectedItemsWidget> {
  StreamSubscription<List<ItemInventoryState>> subscription;
  List<ItemInventoryState> items;

  @override
  void initState() {
    super.initState();

    this.items = widget.service.items;

    subscription = widget.service.broadcaster.listen((selected) {
      this.items = selected;
      setState(() {});
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.service.items.length == 0) {
      return Container();
    }
    return Container(
      color: Colors.grey.shade900,
      child: Column(children: [
        buildHeader(context),
        buildItemIcons(context),
        MultiselectManagementBlockWidget(items: items),
      ]),
    );
  }

  Widget buildHeader(BuildContext context) {
    if (items == null) return Container();
    return HeaderWidget(
      padding: EdgeInsets.all(0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
            padding: EdgeInsets.all(8),
            child: TranslatedTextWidget(
              "{itemCount} items selected",
              key: Key("item_count ${items.length}"),
              uppercase: true,
              style: TextStyle(fontWeight: FontWeight.bold),
              replace: {"itemCount": "${items.length}"},
            )),
        Material(
            color: Theme.of(context).errorColor,
            child: InkWell(
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Row(children: [
                    Icon(
                      Icons.remove_circle,
                      size: 16,
                    ),
                    Container(
                      width: 4,
                    ),
                    TranslatedTextWidget(
                      "Clear",
                      uppercase: true,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ]),
                ),
                onTap: () {
                  widget.service.clear();
                }))
      ]),
    );
  }

  Widget buildItemIcons(BuildContext context) {
    if (items == null) return Container();
    if (items?.length == 1) {
      var item = items[0];
      return Container(
          height: 96,
          key:ObjectKey(item),
          child: 
          QuickSelectItemWrapperWidget(item?.item, null, characterId: item?.characterId,));
    }
    var itemsPerRow = MediaQueryHelper(context).tabletOrBigger ? 20 : 10;
    return Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsets.all(4),
        child: Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,
            spacing: 4,
            runSpacing: 4,
            children: items
                .map((i) => FractionallySizedBox(
                    key: ObjectKey(i),
                    widthFactor: 1 / itemsPerRow,
                    child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                            foregroundDecoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey.shade300, width: .5)),
                            child: Stack(children: [
                              Positioned.fill(
                                  child: ManifestImageWidget<
                                      DestinyInventoryItemDefinition>(
                                i.item.itemHash,
                              )),
                              Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      widget.service
                                          .removeItem(i.item, i.characterId);
                                    },
                                  ))
                            ])))))
                .toList()));
  }
}
