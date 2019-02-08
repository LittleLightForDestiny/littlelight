import 'dart:math';

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:little_light/screens/search.screen.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/widgets/item_list/items/search_item_wrapper.widget.dart';
import 'package:little_light/widgets/search/search_filters.widget.dart';

class SearchListWidget extends StatefulWidget {
  final ProfileService profile = ProfileService();
  final SearchTabData tabData;
  SearchListWidget({Key key, this.tabData}) : super(key: key);
  @override
  SearchListWidgetState createState() => new SearchListWidgetState();
}

class SearchListWidgetState extends State<SearchListWidget> with AutomaticKeepAliveClientMixin{
  String get search => widget.tabData.searchText;
  List<_ItemWithOwner> items;
  Map<int, DestinyInventoryItemDefinition> itemDefinitions;

  @override
  initState() {
    super.initState();
    loadItems();
  }

  loadItems() async {
    List<_ItemWithOwner> allItems = [];
    ProfileService profile = ProfileService();
    ManifestService manifest = ManifestService();
    Iterable<String> charIds =
        profile.getCharacters().map((char) => char.characterId);
    charIds.forEach((charId) {
      allItems.addAll(profile
          .getCharacterEquipment(charId)
          .map((item) => _ItemWithOwner(item, charId)));
      allItems.addAll(profile
          .getCharacterInventory(charId)
          .map((item) => _ItemWithOwner(item, charId)));
    });
    allItems.addAll(profile
        .getProfileInventory()
        .map((item) => _ItemWithOwner(item, null)));
    allItems.sort(
        (a, b) => InventoryUtils.sortDestinyItems(a.item, b.item, profile));
    items = allItems.where((item) {
      return item.item.itemInstanceId != null;
    }).toList();
    Iterable<int> hashes = allItems.map((i) => i.item.itemHash);
    for (var i = 0; i < hashes.length; i += 10) {
      int end = min(i + 10, hashes.length - 1);
      if (itemDefinitions == null) {
        itemDefinitions =
            await manifest.getDefinitions<DestinyInventoryItemDefinition>(
                hashes.toList().sublist(i, end));
      } else {
        itemDefinitions.addAll(
            await manifest.getDefinitions<DestinyInventoryItemDefinition>(
                hashes.toList().sublist(i, end)));
      }
      if (mounted) {
        sortItems();
        setState(() {});
      } else {
        break;
      }
    }
  }

  sortItems(){
    items.sort((itemA, itemB) => InventoryUtils.sortDestinyItems(
        itemA.item, itemB.item, widget.profile,
        defA: itemDefinitions[itemA.item.itemHash],
        defB: itemDefinitions[itemB.item.itemHash],
        sortingParams: widget.tabData.sortOrder));
  }

  Widget build(BuildContext context) {
    return StaggeredGridView.countBuilder(
      padding: EdgeInsets.all(4),
      crossAxisCount: 6,
      itemCount: filteredItems?.length ?? 0,
      itemBuilder: (BuildContext context, int index) => getItem(context, index),
      staggeredTileBuilder: (int index) => getTileBuilder(context, index),
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      physics: const AlwaysScrollableScrollPhysics(),
    );
  }

  FilterItem get powerLevelFilter =>
      widget.tabData.filterData[FilterType.powerLevel];
  FilterItem get damageTypeFilter =>
      widget.tabData.filterData[FilterType.damageType];
  FilterItem get tierTypeFilter =>
      widget.tabData.filterData[FilterType.tierType];
  FilterItem get bucketTypeFilter =>
      widget.tabData.filterData[FilterType.bucketType];
  FilterItem get subtypeFilter =>
      widget.tabData.filterData[FilterType.itemSubType];
  FilterItem get typeFilter =>
      widget.tabData.filterData[FilterType.itemType];
  FilterItem get ammoTypeFilter =>
      widget.tabData.filterData[FilterType.ammoType];
  FilterItem get classTypeFilter =>
      widget.tabData.filterData[FilterType.classType];

  List<_ItemWithOwner> get filteredItems {
    if (itemDefinitions == null) return [];

    return items.where((item) {
      var def = itemDefinitions[item.item.itemHash];
      if (def == null) return false;
      if (widget.tabData.itemTypes != null &&
          !widget.tabData.itemTypes.contains(def.itemType)) {
        return false;
      }
      if (widget.tabData.excludeItemTypes != null &&
          widget.tabData.excludeItemTypes.contains(def.itemType)) {
        return false;
      }
      if (powerLevelFilter != null) {
        var values = powerLevelFilter.values;
        DestinyItemInstanceComponent instance =
            ProfileService().getInstanceInfo(item.item.itemInstanceId);
        int power = instance?.primaryStat?.value;
        if (power != null && (power > values[1])) {
          return false;
        }
      }

      if (damageTypeFilter != null) {
        var values = damageTypeFilter.values;
        DestinyItemInstanceComponent instance =
            ProfileService().getInstanceInfo(item.item.itemInstanceId);
        int damageType = instance?.damageType;

        if (damageType != null &&
            values.length != 0 &&
            !values.contains(damageType)) {
          return false;
        }
      }

      if (tierTypeFilter != null) {
        var values = tierTypeFilter.values;
        var tier = def?.inventory?.tierType;

        if (tier != null && values.length != 0 && !values.contains(tier)) {
          return false;
        }
      }

      if (bucketTypeFilter != null) {
        var values = bucketTypeFilter.values;
        var bucketHash = def?.inventory?.bucketTypeHash;

        if (bucketHash != null &&
            values.length != 0 &&
            !values.contains(bucketHash)) {
          return false;
        }
      }

      if (typeFilter != null) {
        var values = typeFilter.values;
        var type = def?.itemType;
        if (type != null &&
            values.length != 0 &&
            !values.contains(type)) {
          return false;
        }
      }

      if (subtypeFilter != null) {
        var values = subtypeFilter.values;
        var subtype = def?.itemSubType;
        if (subtype != null &&
            values.length != 0 &&
            !values.contains(subtype)) {
          return false;
        }
      }

      if (ammoTypeFilter != null) {
        var values = ammoTypeFilter.values;
        var ammoType = def?.equippingBlock?.ammoType;
        if (ammoType != null &&
            values.length != 0 &&
            !values.contains(ammoType)) {
          return false;
        }
      }

      if (classTypeFilter != null) {
        var values = classTypeFilter.values;
        var classType = def?.classType;
        if (classType != null &&
            values.length != 0 &&
            !values.contains(classType)) {
          return false;
        }
      }

      if (search.length == 0) {
        return true;
      }
      if (search.length < 4) {
        return def.displayProperties.name
            .toLowerCase()
            .startsWith(search.toLowerCase());
      }
      return def.displayProperties.name
          .toLowerCase()
          .contains(search.toLowerCase());
    }).toList();
  }

  StaggeredTile getTileBuilder(BuildContext context, int index) {
    return StaggeredTile.extent(6, 96);
  }

  Widget getItem(BuildContext context, int index) {
    var item = filteredItems[index];
    if (itemDefinitions == null || itemDefinitions[item.item.itemHash] == null)
      return Container();
    return SearchItemWrapperWidget(item.item,
        itemDefinitions[item.item.itemHash]?.inventory?.bucketTypeHash,
        characterId: item.ownerId,
        key: Key("item_${item.item.itemInstanceId}_${item.item.itemHash}"));
  }

  @override
  bool get wantKeepAlive => true;
}

class _ItemWithOwner {
  DestinyItemComponent item;
  String ownerId;
  _ItemWithOwner(this.item, this.ownerId);
}
