import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/modules/search/blocs/search_sorter.bloc.dart';
import 'package:little_light/modules/search/widgets/drawer_sorters/available_sorter.widget.dart';
import 'package:little_light/shared/widgets/headers/header.wiget.dart';
import 'package:provider/provider.dart';

import 'drawer_sorters/active_sorter.widget.dart';

class SortersListWidget extends StatelessWidget {
  final EdgeInsets? padding;
  const SortersListWidget({Key? key, this.padding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SearchSorterBloc>();
    final active = state.active;
    return SingleChildScrollView(
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.all(4),
            child: HeaderWidget(child: Text("Active Sorters".translate(context).toUpperCase())),
          ),
          if (active.isNotEmpty)
            ReorderableList(
              shrinkWrap: true,
              itemCount: active.length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => Container(
                  key: Key("${active[index].type}_$index"),
                  child: ActiveSorterWidget.fromParameter(active[index], index)),
              onReorder: (int oldIndex, int newIndex) {
                context.read<SearchSorterBloc>().reorderSorters(oldIndex, newIndex);
              },
            ),
          Container(
            margin: EdgeInsets.all(4),
            child: HeaderWidget(child: Text("Available Sorters".translate(context).toUpperCase())),
          ),
          ...state.available.map((s) => AvailableSorterWidget.fromParameter(s)).toList()
        ],
      ),
    );
  }
}
