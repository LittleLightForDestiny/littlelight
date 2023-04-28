import 'package:flutter/material.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/base_filter_values_options.dart';

abstract class BaseItemFilter<T extends BaseFilterOptions> {
  T data;

  BaseItemFilter(this.data);

  @mustCallSuper
  Future<List<DestinyItemInfo>> filter(BuildContext context, List<DestinyItemInfo> items) async {
    if (!data.available || !data.enabled) return items.toList();
    final result = <DestinyItemInfo>[];
    for (final item in items) {
      final keep = await filterItem(item);
      if (keep) result.add(item);
    }
    return result;
  }

  Future<bool> filterItem(DestinyItemInfo item);

  Future<void> addValue(DestinyItemInfo item) async {}

  void updateValue(T t) {
    data.value = t.value;
  }

  void updateEnabled(bool enabled) {
    data.enabled = enabled;
  }
}
