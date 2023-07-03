import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/modules/search/blocs/search_filter.bloc.dart';
import 'package:little_light/modules/search/blocs/search_sorter.bloc.dart';
import 'package:little_light/shared/blocs/item_interaction_handler/item_interaction_handler.bloc.dart';
import 'package:provider/provider.dart';

import 'pursuit_search.bloc.dart';
import 'pursuit_search.view.dart';

class PursuitSearchPage extends StatelessWidget {
  const PursuitSearchPage({
    Key? key,
  }) : super(key: key);

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
        ChangeNotifierProvider(
          create: (context) {
            return PursuitSearchBloc(context);
          },
        ),
        Provider<ItemInteractionHandlerBloc>(create: (context) {
          final bloc = context.read<PursuitSearchBloc>();
          return ItemInteractionHandlerBloc(
            onTap: (item) => item is InventoryItemInfo ? bloc.onItemTap(item) : null,
            onHold: (item) => item is InventoryItemInfo ? bloc.onItemHold(item) : null,
          );
        }),
      ],
      builder: (context, _) => PursuitSearchView(
        context.read<PursuitSearchBloc>(),
        context.watch<PursuitSearchBloc>(),
      ),
    );
  }
}
