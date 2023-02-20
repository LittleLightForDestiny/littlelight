import 'package:flutter/material.dart';
import 'package:little_light/modules/search/blocs/filter_adapter.bloc.dart';
import 'package:little_light/modules/search/blocs/filter_types/base_filter_values_wrapper.dart';
import 'package:provider/provider.dart';

abstract class BaseFilterWidget<T extends BaseFilterValuesWrapper> extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final filter = context.watch<FilterAdapterBloc>().getFilter<T>();
    if (filter is T) {
      return buildWithData(context, filter as T);
    }
    return Container();
  }

  Widget buildWithData(BuildContext context, T? data);

  void update(BuildContext context, T value) {
    context.read<FilterAdapterBloc>().updateValue(value);
  }
}
