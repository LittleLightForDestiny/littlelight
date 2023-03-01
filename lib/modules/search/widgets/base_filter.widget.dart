import 'package:flutter/material.dart';
import 'package:little_light/modules/search/blocs/filter_adapter.bloc.dart';
import 'package:little_light/modules/search/blocs/filter_options/base_filter_values_options.dart';
import 'package:provider/provider.dart';

abstract class BaseFilterWidget<T extends BaseFilterOptions>
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final filter = context.watch<FilterAdapterBloc>().getFilter<T>();
    if (filter is T && filter.available) {
      return buildWithData(context, filter);
    }
    return Container();
  }

  Widget buildWithData(BuildContext context, T data);

  void update(BuildContext context, T value) {
    context.read<FilterAdapterBloc>().updateValue<T>(value);
  }

  void updateEnabled(BuildContext context, bool value) {
    context.read<FilterAdapterBloc>().updateEnabledStatus<T>(value);
  }
}
