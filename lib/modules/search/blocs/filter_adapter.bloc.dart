import 'package:flutter/material.dart';
import 'package:little_light/modules/search/blocs/filter_types/base_filter_values_wrapper.dart';

typedef UpdateFilterValue = void Function<T extends BaseFilterValuesWrapper>(T value);

class FilterAdapterBloc extends ChangeNotifier {
  final Map<Type, BaseFilterValuesWrapper> _filters;
  final UpdateFilterValue? _updateFilterValue;
  FilterAdapterBloc(this._filters, {UpdateFilterValue? onUpdateFilterValue})
      : this._updateFilterValue = onUpdateFilterValue;
  BaseFilterValuesWrapper? getFilter<T extends BaseFilterValuesWrapper>() => _filters[T];

  void updateValue<T extends BaseFilterValuesWrapper>(T value) {
    if (_updateFilterValue == null) return;
    _updateFilterValue?.call<T>(value);
  }
}
