import 'package:flutter/material.dart';
import 'package:little_light/modules/search/blocs/filter_options/base_filter_values_options.dart';
import 'package:little_light/modules/search/blocs/search_filter.bloc.dart';
import 'package:provider/provider.dart';

abstract class BaseFilterWidget<T extends BaseFilterOptions> extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final filter = context.watch<SearchFilterBloc>().getFilter<T>();
    if (filter is T && filter.available) {
      return buildWithData(context, filter);
    }
    return Container();
  }

  Widget buildWithData(BuildContext context, T data);

  void update(BuildContext context, T value) {
    context.read<SearchFilterBloc>().updateValue<T>(value);
  }

  void updateEnabled(BuildContext context, bool value) {
    context.read<SearchFilterBloc>().updateEnabledStatus<T>(value);
  }
}
