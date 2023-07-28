import 'package:flutter/material.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/crafted_filter_options.dart';
import 'package:little_light/modules/search/blocs/filter_options/deepsight_filter_options.dart';
import 'package:little_light/modules/search/blocs/filter_options/item_bucket_type_filter_options.dart';
import 'package:little_light/modules/search/blocs/filter_options/weapon_frame_filter_options.dart';
import 'package:little_light/modules/search/blocs/filters/crafted_filter.dart';
import 'package:little_light/modules/search/blocs/filters/deepsight_filter.dart';
import 'package:little_light/modules/search/blocs/filters/export.dart';
import 'package:little_light/modules/search/blocs/filters/weapon_frame_filter.dart';
import 'filter_options/export.dart';
import 'filters/item_bucket_type_filter.dart';

_defaultSearchFilters(BuildContext context) => <Type, BaseItemFilter>{
      /// generic filters (all item types)
      TextFilterOptions: TextFilter(),
      PowerLevelFilterOptions: PowerLevelFilter(),
      ItemBucketTypeFilterOptions: ItemBucketTypeFilter(),
      ItemBucketFilterOptions: ItemBucketFilter(),
      ItemSubtypeFilterOptions: ItemSubtypeFilter(),
      TierTypeFilterOptions: TierTypeFilter(),
      ItemOwnerFilterOptions: ItemOwnerFilter(),

      /// weapon filter types
      AmmoTypeFilterOptions: AmmoTypeFilter(),
      DamageTypeFilterOptions: DamageTypeFilter(),
      DeepsightFilterOptions: DeepsightFilter(),
      CraftedFilterOptions: CraftedFilter(),
      WeaponFrameFilterOptions: WeaponFrameFilter(),

      /// armor filter types
      EnergyLevelFilterOptions: EnergyLevelFilter(),
      ClassTypeFilterOptions: ClassTypeFilter(),
      ArmorStatsFilterOptions: ArmorStatsFilter(),

      /// LL specific stuff
      ItemTagFilterOptions: ItemTagFilter(context),
      LoadoutFilterOptions: LoadoutFilter(context),
      WishlistTagFilterOptions: WishlistTagFilter()
    };

class SearchFilterBloc extends ChangeNotifier {
  final BuildContext _context;
  final Map<Type, BaseItemFilter> _filters;

  SearchFilterBloc(BuildContext this._context, {Map<Type, BaseItemFilter>? filters})
      : _filters = filters ?? _defaultSearchFilters(_context);
  T? getFilter<T extends BaseFilterOptions>() => _filters[T]?.data as T?;

  void updateValue<T extends BaseFilterOptions>(T value) {
    final filter = this._filters[T];
    if (filter == null) return;
    filter.updateValue(value);
    notifyListeners();
  }

  void updateEnabledStatus<T extends BaseFilterOptions>(bool enable) {
    final filter = this._filters[T];
    if (filter == null) return;
    filter.updateEnabled(enable);
    notifyListeners();
  }

  void changeSetValue<Y, T extends BaseFilterOptions<Set<Y>>>(T type, Y value, [bool forceAdd = false]) {
    final filter = this._filters[T];
    if (filter == null) return;
    final elements = type.value.toSet();
    final multiselect = forceAdd || elements.length > 1;
    final isSelected = elements.contains(value);
    if (multiselect && !isSelected) {
      elements.add(value);
    } else if (isSelected) {
      elements.remove(value);
    } else {
      elements.clear();
      elements.add(value);
    }
    type.value = elements;
    filter.updateValue(type);
    notifyListeners();
  }

  void addValues(List<DestinyItemInfo> item) async {
    for (final f in _filters.values) {
      f.addValues(item);
    }
  }

  Future<List<DestinyItemInfo>> filter(List<DestinyItemInfo> items) async {
    for (final _filter in _filters.values) {
      items = await _filter.filter(_context, items);
    }
    return items;
  }

  void clearValues() {
    for (final f in _filters.values) {
      f.clearAvailable();
    }
  }
}
