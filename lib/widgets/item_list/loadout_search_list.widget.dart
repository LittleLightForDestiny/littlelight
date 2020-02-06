import 'package:bungie_api/enums/destiny_class.dart';
import 'package:bungie_api/enums/destiny_item_type.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/user_settings/item_sort_parameter.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/widgets/item_list/items/loadout_search_item_wrapper.widget.dart';
import 'package:little_light/widgets/item_list/search_list.widget.dart';
import 'package:little_light/widgets/search/search_filters.widget.dart';

class LoadoutSearchListWidget extends SearchListWidget {
  final String searchText;
  final int bucketType;
  final DestinyClass classType;
  final Iterable<String> idsToAvoid;
  LoadoutSearchListWidget({Key key, this.searchText, this.bucketType, this.classType, this.idsToAvoid}) : super(key: key);

  @override
  LoadoutSearchListWidgetState createState() => LoadoutSearchListWidgetState();
}

class LoadoutSearchListWidgetState
    extends SearchListWidgetState<LoadoutSearchListWidget> {
  @override
  String get search => widget.searchText;
  
  @override
  FilterItem get powerLevelFilter => null;
  
  @override
  FilterItem get damageTypeFilter => null;
  
  @override
  FilterItem get tierTypeFilter => null;
  
  @override
  FilterItem get bucketTypeFilter => FilterItem([widget.bucketType], [widget.bucketType]);
  
  @override
  FilterItem get subtypeFilter => null;
  
  @override
  FilterItem get typeFilter => null;
  
  @override
  FilterItem get ammoTypeFilter => null;
  
  @override
  FilterItem get classTypeFilter => widget.classType != null ? FilterItem([widget.classType, DestinyClass.Unknown], [widget.classType, DestinyClass.Unknown]) : null;

  @override
  List<DestinyItemType> get itemTypes => null;
  
  @override
  List<int> get excludeItemTypes => null;

  @override
  List<ItemSortParameter> get sortOrder => [ItemSortParameter(type:ItemSortParameterType.PowerLevel, direction:-1)];

  @override
  List<ItemWithOwner> get filteredItems {
    var items = super.filteredItems;
    if(widget.idsToAvoid != null){
      items = items.where((item)=>!widget.idsToAvoid.contains(item.item.itemInstanceId)).toList();
    }
    return items;
  }

  @override
  Widget getItem(BuildContext context, int index, _items) {
    if(_items == null) return null;
    if(index > _items.length - 1) return null;
    var item = _items[index];
    if (itemDefinitions == null || itemDefinitions[item.item.itemHash] == null)
      return Container();
    return LoadoutSearchItemWrapperWidget(item.item,
        itemDefinitions[item.item.itemHash]?.inventory?.bucketTypeHash,
        characterId: item.ownerId,
        key: Key("item_${item.item.itemInstanceId}_${item.item.itemHash}"));
  }
}
