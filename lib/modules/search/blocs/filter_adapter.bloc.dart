import 'package:flutter/material.dart';
import 'package:little_light/modules/search/blocs/filter_options/base_filter_values_options.dart';

typedef UpdateFilterValue = void Function<T extends BaseFilterOptions>(T value);
typedef UpdateFilterEnabledStatus = void Function<T extends BaseFilterOptions>(
    bool value);
typedef ChangeSetValue = void Function<Y, T extends BaseFilterOptions<Set<Y>>>(
    T type, Y value, bool forceAdd);

class FilterAdapterBloc extends ChangeNotifier {
  final Map<Type, BaseFilterOptions> _filters;
  final UpdateFilterValue? _updateFilterValue;
  final UpdateFilterEnabledStatus? _updateFilterEnabledStatus;
  final ChangeSetValue? _changeSetValue;
  FilterAdapterBloc(
    this._filters, {
    UpdateFilterValue? onUpdateFilterValue,
    UpdateFilterEnabledStatus? onUpdateFilterEnabledStatus,
    ChangeSetValue? onChangeSetValue,
  })  : this._updateFilterValue = onUpdateFilterValue,
        this._updateFilterEnabledStatus = onUpdateFilterEnabledStatus,
        this._changeSetValue = onChangeSetValue;
  BaseFilterOptions? getFilter<T extends BaseFilterOptions>() => _filters[T];

  void updateValue<T extends BaseFilterOptions>(T value) {
    _updateFilterValue?.call<T>(value);
  }

  void updateEnabledStatus<T extends BaseFilterOptions>(bool enable) {
    _updateFilterEnabledStatus?.call<T>(enable);
  }

  void changeSetValue<Y, T extends BaseFilterOptions<Set<Y>>>(T type, Y value,
      [bool forceAdd = false]) {
    _changeSetValue?.call<Y, T>(type, value, forceAdd);
  }
}
