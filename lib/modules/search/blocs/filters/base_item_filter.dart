import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_types/base_filter_values_wrapper.dart';

abstract class BaseItemFilter<T extends BaseFilterValuesWrapper> {
  T data;
  bool available = true;
  bool enabled;

  BaseItemFilter(this.data, {this.enabled = false});

  @mustCallSuper
  Future<List<DestinyItemInfo>> filter(BuildContext context, List<DestinyItemInfo> items) async {
    if (!available || !enabled) return items.toList();
    final result = <DestinyItemInfo>[];
    for (final item in items) {
      final keep = await filterItem(item);
      if (keep) result.add(item);
    }
    return result;
  }

  Future<bool> filterItem(DestinyItemInfo item);

  void updateValue(T t);
}
