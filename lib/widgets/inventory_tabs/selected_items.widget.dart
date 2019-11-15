import 'dart:async';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/inventory/inventory.service.dart';
import 'package:little_light/services/selection/selection.service.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/inventory_tabs/multiselect_management_block.widget.dart';

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
    this.items = widget.service.items;
    super.initState();
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
    if (!widget.service.multiselectActivated) {
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
    if(items == null) return Container();
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
    if(items == null) return Container();
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
                    widthFactor: 1 / 10,
                    child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                            foregroundDecoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey.shade300, width: .5)),
                            child: Stack(children: [
                              ManifestImageWidget<
                                      DestinyInventoryItemDefinition>(
                                  i.item.itemHash),
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
