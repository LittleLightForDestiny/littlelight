import 'dart:async';
import 'dart:math';

import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:little_light/screens/item_detail.screen.dart';
import 'package:little_light/services/notification/notification.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/services/selection/selection.service.dart';
import 'package:little_light/services/user_settings/user_settings.service.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/item_list/items/base/base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/base/base_item_instance.widget.dart';
import 'package:little_light/widgets/search/search.controller.dart';
import 'package:shimmer/shimmer.dart';

enum DuplicatedListItemType {
  bucketTitle,
  itemDefinition,
  itemInstance,
  spacer
}

class DuplicatedListItem {
  final DuplicatedListItemType type;
  final int hash;
  final DestinyItemComponent item;
  final List<ItemWithOwner> items;
  final String ownerId;
  DuplicatedListItem(this.type,
      {this.hash, this.item, this.ownerId, this.items});
}

class DuplicatedItemListWidget extends StatefulWidget {
  final ProfileService profile = ProfileService();
  final SearchController searchController;
  DuplicatedItemListWidget({Key key, this.searchController}) : super(key: key);
  final NotificationService broadcaster = new NotificationService();

  @override
  DuplicatedItemListWidgetState createState() =>
      new DuplicatedItemListWidgetState();
}

class DuplicatedItemListWidgetState extends State<DuplicatedItemListWidget>
    with AutomaticKeepAliveClientMixin {
  List<DuplicatedListItem> listItems;

  @override
  initState() {
    super.initState();
    widget.searchController?.addListener(update);
  }

  @override
  dispose() {
    super.dispose();
    widget.searchController?.removeListener(update);
  }

  void update() {
    if (widget.searchController.filtered == null) return;
    listItems = [];
    var items = widget.searchController.filtered;
    Map<int, List<ItemWithOwner>> itemsByHash = {};
    for (var item in items) {
      var hash = item.item.itemHash;
      if (!itemsByHash.containsKey(hash)) {
        itemsByHash[hash] = [];
      }
      itemsByHash[hash].add(item);
    }
    itemsByHash.removeWhere((k, v) => v.length < 2);
    for (var hash in itemsByHash.keys) {
      // items.add(DuplicatedListItem(DuplicatedListItemType.bucketTitle,
      //     hash: bucketHash));
      var instances = itemsByHash[hash];
      listItems.add(DuplicatedListItem(DuplicatedListItemType.itemDefinition,
          hash: hash, items: instances));
      for (var instance in instances) {
        listItems.add(DuplicatedListItem(DuplicatedListItemType.itemInstance,
            hash: hash, item: instance.item, ownerId: instance.ownerId));
      }
      listItems.add(DuplicatedListItem(DuplicatedListItemType.spacer));
    }
    if (mounted) {
      setState(() {});
    }
  }

  Widget build(BuildContext context) {
    super.build(context);
    if (listItems == null) {
      return Center(
          child: Container(
              width: 96,
              child: Shimmer.fromColors(
                baseColor: Colors.blueGrey.shade300,
                highlightColor: Colors.white,
                child: Image.asset("assets/anim/loading.webp"),
              )));
    }
    var screenPadding = MediaQuery.of(context).padding;
    return StaggeredGridView.countBuilder(
      padding: EdgeInsets.all(4).copyWith(
          left: max(screenPadding.left, 4),
          right: max(screenPadding.right, 4),
          bottom: screenPadding.bottom + 150),
      crossAxisCount: 6,
      itemCount: listItems?.length ?? 0,
      itemBuilder: (BuildContext context, int index) => getItem(context, index),
      staggeredTileBuilder: (int index) => getTileBuilder(context, index),
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      physics: const AlwaysScrollableScrollPhysics(),
    );
  }

  StaggeredTile getTileBuilder(BuildContext context, int index) {
    var item = listItems[index];
    switch (item.type) {
      case DuplicatedListItemType.bucketTitle:
        return StaggeredTile.extent(6, 40);

      case DuplicatedListItemType.itemDefinition:
        return StaggeredTile.extent(6, 96);
      case DuplicatedListItemType.itemInstance:
        if (MediaQueryHelper(context).laptopOrBigger) {
          return StaggeredTile.extent(1, 132);
        }
        if (MediaQueryHelper(context).tabletOrBigger) {
          return StaggeredTile.extent(2, 132);
        }
        return StaggeredTile.extent(3, 132);

      case DuplicatedListItemType.spacer:
        return StaggeredTile.extent(6, 20);
    }
    return StaggeredTile.extent(6, 96);
  }

  Widget getItem(BuildContext context, int index) {
    if (listItems == null) return null;
    if (index > listItems.length - 1) return null;
    var item = listItems[index];
    switch (item.type) {
      case DuplicatedListItemType.bucketTitle:
        return HeaderWidget(
          alignment: Alignment.centerLeft,
          child: ManifestText<DestinyInventoryBucketDefinition>(
            item.hash,
            uppercase: true,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        );

      case DuplicatedListItemType.itemDefinition:
        return _DefinitionItemWrapper(item.hash, item.items);

      case DuplicatedListItemType.itemInstance:
        return DefinitionProviderWidget<DestinyInventoryItemDefinition>(
            item.hash,
            (def) => _ItemInstanceWrapper(
                  item: item.item,
                  definition: def,
                  characterId: item.ownerId,
                ),
            key: Key(
                "item_${item.hash}_${item.item.itemInstanceId}_${item.ownerId}"));

      case DuplicatedListItemType.spacer:
        return Container();
    }
    return Container();
  }

  @override
  bool get wantKeepAlive => true;
}

class _DefinitionItemWrapper extends StatefulWidget {
  final int hash;
  final List<ItemWithOwner> items;
  _DefinitionItemWrapper(this.hash, this.items);
  @override
  State<StatefulWidget> createState() {
    return _DefinitionItemWrapperState();
  }
}

class _DefinitionItemWrapperState extends State<_DefinitionItemWrapper> {
  bool get selected => widget.items.every((i) {
        return SelectionService().isSelected(i);
      });

  @override
  void initState() {
    super.initState();

    StreamSubscription<List<ItemWithOwner>> sub;
    sub = SelectionService().broadcaster.listen((selectedItems) {
      if (!mounted) {
        sub.cancel();
        return;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(key: Key("itemdef_${widget.hash}"), children: [
      DefinitionProviderWidget<DestinyInventoryItemDefinition>(
          widget.hash,
          (def) => BaseInventoryItemWidget(
                null,
                def,
                null,
                characterId: null,
                uniqueId: null,
              )),
      selected
          ? Positioned.fill(
              child: Container(
                foregroundDecoration: BoxDecoration(
                    border:
                        Border.all(color: Colors.lightBlue.shade400, width: 2)),
              ),
            )
          : Container(),
      buildInkWell(context)
    ]);
  }

  Widget buildInkWell(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(context),
        onLongPress: () => onTap(context),
      ),
    );
  }

  void onTap(context) {
    if (selected) {
      for (var item in widget.items) {
        SelectionService().removeItem(item);
      }
    } else {
      SelectionService().activateMultiSelect();
      for (var item in widget.items) {
        if (!SelectionService().isSelected(item)) {
          SelectionService().addItem(item);
        }
      }
    }
  }
}

class _ItemInstanceWrapper extends StatefulWidget {
  final DestinyItemComponent item;
  final DestinyInventoryItemDefinition definition;
  final String characterId;

  _ItemInstanceWrapper({Key key, this.item, this.definition, this.characterId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ItemInstanceWrapperState();
  }
}

class _ItemInstanceWrapperState extends State<_ItemInstanceWrapper> {
  DestinyItemInstanceComponent instance;
  bool get selected => SelectionService()
      .isSelected(ItemWithOwner(widget.item, widget.characterId));

  @override
  void initState() {
    super.initState();

    instance = ProfileService().getInstanceInfo(widget.item.itemInstanceId);

    StreamSubscription<List<ItemWithOwner>> sub;
    sub = SelectionService().broadcaster.listen((selectedItems) {
      if (!mounted) {
        sub.cancel();
        return;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(
          child: BaseItemInstanceWidget(
              widget.item, widget.definition, instance,
              characterId: widget.characterId, uniqueId: null)),
      selected
          ? Positioned.fill(
              child: Container(
                foregroundDecoration: BoxDecoration(
                    border:
                        Border.all(color: Colors.lightBlue.shade400, width: 2)),
              ),
            )
          : Container(),
      buildInkWell(context)
    ]);
  }

  Widget buildInkWell(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        enableFeedback: false,
        onTap: () => onTap(context),
        onLongPress: () => onLongPress(context),
      ),
    );
  }

  void onTap(context) {
    if (SelectionService().multiselectActivated) {
      onLongPress(context);
      return;
    }
    if (UserSettingsService().tapToSelect) {
      SelectionService()
          .setItem(ItemWithOwner(widget.item, widget.characterId));
      return;
    }
    SelectionService().clear();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailScreen(
          item: widget.item,
          definition: widget.definition,
          instanceInfo: instance,
          characterId: widget.characterId,
          uniqueId: null,
        ),
      ),
    );
  }

  void onLongPress(context) {
    if (widget.definition.nonTransferrable) return;
    SelectionService().activateMultiSelect();
    SelectionService().addItem(ItemWithOwner(widget.item, widget.characterId));
    setState(() {});
  }
}
