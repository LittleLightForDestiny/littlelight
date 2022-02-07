// @dart=2.9

import 'dart:async';

import 'package:bungie_api/enums/item_state.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/pages/item_details/item_details.page.dart';
import 'package:little_light/services/inventory/inventory.consumer.dart';
import 'package:little_light/services/inventory/inventory.package.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/services/selection/selection.consumer.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

import 'package:little_light/widgets/inventory_tabs/multiselect_management_block.widget.dart';
import 'package:little_light/widgets/item_list/items/quick_select_item_wrapper.widget.dart';

class SelectedItemsWidget extends StatefulWidget {

  SelectedItemsWidget({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SelectedItemsWidgetState();
  }
}

class SelectedItemsWidgetState extends State<SelectedItemsWidget> with ProfileConsumer, InventoryConsumer, ManifestConsumer, SelectionConsumer {
  StreamSubscription<List<ItemWithOwner>> subscription;
  List<ItemWithOwner> items;

  @override
  void initState() {
    super.initState();

    this.items = selection.items;

    subscription = selection.broadcaster.listen((selected) {
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
    if (selection.items.length == 0) {
      return Container();
    }
    return Container(
      color: Colors.grey.shade900,
      child: Column(children: [
        buildHeader(context),
        buildItemIcons(context),
        buildOptions(context),
        MultiselectManagementBlockWidget(items: items),
      ]),
    );
  }

  Widget buildOptions(BuildContext context) {
    var buttons = <ElevatedButton>[];
    var lockableItems = items.where((i) =>
        i?.item?.lockable == true &&
        i?.item?.state?.contains(ItemState.Locked) != true);
    var unlockableItems = items.where((i) =>
        i?.item?.lockable == true &&
        i?.item?.state?.contains(ItemState.Locked) != false);
    if (lockableItems.length > 0) {
      buttons.add(ElevatedButton(
        key: Key("lock_button"),
        child: TranslatedTextWidget(
          "Lock",
          uppercase: true,
        ),
        onPressed: () async {
          inventory
              .changeMultipleLockState(lockableItems.toList(), true);
          setState(() {});
        },
      ));
    }
    if (unlockableItems.length > 0) {
      buttons.add(ElevatedButton(
        key: Key("unlock_button"),
        child: TranslatedTextWidget(
          "Unlock",
          uppercase: true,
        ),
        onPressed: () async {
          inventory
              .changeMultipleLockState(unlockableItems.toList(), false);
          setState(() {});
        },
      ));
    }
    if (items.length == 1) {
      buttons.add(ElevatedButton(
        child: TranslatedTextWidget(
          "Details",
          uppercase: true,
        ),
        onPressed: () async {
          var item = items.single;
          var instanceInfo =
              profile.getInstanceInfo(item?.item?.itemInstanceId);
          var def = await manifest
              .getDefinition<DestinyInventoryItemDefinition>(
                  item?.item?.itemHash);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemDetailsPage(
                item: item.item,
                definition: def,
                instanceInfo: instanceInfo,
                characterId: item.ownerId,
              ),
            ),
          );
        },
      ));
    }
    return Row(
        children: buttons
            .map((b) => Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: b,
                  ),
                ))
            .toList());
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
                  selection.clear();
                }))
      ]),
    );
  }

  Widget buildItemIcons(BuildContext context) {
    if (items == null) return Container();
    if (items?.length == 1) {
      var item = items[0];
      return Container(
          key: ObjectKey(item),
          child: QuickSelectItemWrapperWidget(
            item?.item,
            null,
            characterId: item?.ownerId,
          ));
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
                                      selection.removeItem(i);
                                    },
                                  ))
                            ])))))
                .toList()));
  }
}
