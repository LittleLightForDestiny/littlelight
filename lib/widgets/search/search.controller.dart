import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/widgets.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/item_filters/base_item_filter.dart';
import 'package:little_light/utils/item_with_owner.dart';

class SearchController extends ChangeNotifier {
  List<ItemWithOwner> _unfilteredList;
  List<ItemWithOwner> _filteredList;
  List<ItemWithOwner> get filtered => _filteredList;
  Map<int, DestinyInventoryItemDefinition> _itemDefinitions;

  List<BaseItemFilter> filters;

  SearchController({
    this.filters = const [],
  }) {
    _init();
  }

  _init() async {
    this._unfilteredList = _getItems();
    this._itemDefinitions = await _loadDefinitions();
    this._filteredList = _unfilteredList.toList();
    notifyListeners();
  }

  update() async {
    this._filteredList = _unfilteredList.where((item) {
      for (var filter in this.filters) {
        var result = filter.filter(item, definitions: _itemDefinitions);
        if (result == false) return false;
      }
      return true;
    }).toList();
    notifyListeners();
  }

  List<ItemWithOwner> _getItems() {
    List<ItemWithOwner> allItems = [];
    ProfileService profile = ProfileService();
    Iterable<String> charIds =
        profile.getCharacters().map((char) => char.characterId);
    charIds.forEach((charId) {
      allItems.addAll(profile
          .getCharacterEquipment(charId)
          .map((item) => ItemWithOwner(item, charId)));
      allItems.addAll(profile
          .getCharacterInventory(charId)
          .map((item) => ItemWithOwner(item, charId)));
    });
    allItems.addAll(
        profile.getProfileInventory().map((item) => ItemWithOwner(item, null)));
    return allItems;
  }

  _loadDefinitions() async {
    Set<int> hashes = Set();
    _unfilteredList.forEach((item) {
      hashes.add(item?.item?.itemHash);
      var sockets = ProfileService().getItemSockets(item?.item?.itemInstanceId);
      var reusablePlugs =
          ProfileService().getItemReusablePlugs(item?.item?.itemInstanceId);
      hashes.addAll(sockets?.map((s)=>s.plugHash) ?? []);
      reusablePlugs?.values?.forEach((plug) { 
        hashes.addAll(plug?.map((p)=>p.plugItemHash) ?? []);
      });
    });
    var _defs = await ManifestService()
        .getDefinitions<DestinyInventoryItemDefinition>(hashes?.where((element) => element != null));
    return _defs;
  }
}
