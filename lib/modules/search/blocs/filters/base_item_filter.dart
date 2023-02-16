import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';

abstract class BaseItemFilter<T> {
  T availableValues;
  T value;

  bool available = true;
  bool enabled;

  BaseItemFilter(this.availableValues, this.value, {this.enabled = false});

  @mustCallSuper
  Future<List<DestinyItemInfo>> filter(List<DestinyItemInfo> items) async {
    if (!available || !enabled) return items.toList();
    final result = <DestinyItemInfo>[];
    for (final item in items) {
      final keep = await filterItem(item);
      if (keep) result.add(item);
    }
    return result;
  }

  Future<bool> filterItem(DestinyItemInfo item);
}
