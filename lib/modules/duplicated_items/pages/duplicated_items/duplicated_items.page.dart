import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/modules/duplicated_items/pages/duplicated_items/duplicated_items.bloc.dart';
import 'package:little_light/modules/duplicated_items/pages/duplicated_items/duplicated_items.view.dart';
import 'package:little_light/modules/search/blocs/search_filter.bloc.dart';
import 'package:little_light/modules/search/blocs/search_sorter.bloc.dart';
import 'package:little_light/shared/blocs/item_interaction_handler/item_interaction_handler.bloc.dart';
import 'package:provider/provider.dart';

class DuplicatedItemsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SearchFilterBloc(context)),
        ChangeNotifierProvider<SearchSorterBloc>(create: (context) {
          final activeSorters =
              context.read<UserSettingsBloc>().itemOrdering?.where((s) => s.active).toList() ?? <ItemSortParameter>[];
          return SearchSorterBloc(context, activeSorters: activeSorters);
        }),
        ChangeNotifierProvider(create: (context) => DuplicatedItemsBloc(context)),
        Provider<ItemInteractionHandlerBloc>(create: (context) {
          final bloc = context.read<DuplicatedItemsBloc>();
          return ItemInteractionHandlerBloc(
            onTap: (item) => bloc.onItemTap(item),
            onHold: (item) => bloc.onItemHold(item),
          );
        }),
      ],
      builder: (context, _) => DuplicatedItemsView(
        context.read<DuplicatedItemsBloc>(),
        context.watch<DuplicatedItemsBloc>(),
      ),
    );
  }
}
