import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/modules/search/blocs/search_filter.bloc.dart';
import 'package:little_light/modules/search/blocs/search_sorter.bloc.dart';
import 'package:little_light/shared/blocs/item_interaction_handler/item_interaction_handler.bloc.dart';
import 'package:provider/provider.dart';
import 'select_loadout_item.bloc.dart';
import 'select_loadout_item.page_route.dart';
import 'select_loadout_item.view.dart';

class SelectLoadoutItemPage extends StatelessWidget {
  const SelectLoadoutItemPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = SelectLoadoutItemPageRouteArguments.of(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SearchFilterBloc(context)),
        ChangeNotifierProvider<SearchSorterBloc>(create: (context) {
          final activeSorters =
              context.read<UserSettingsBloc>().itemOrdering?.where((s) => s.active).toList() ?? <ItemSortParameter>[];
          return SearchSorterBloc(context, activeSorters: activeSorters);
        }),
        ChangeNotifierProvider(
          create: (context) => SelectLoadoutItemBloc(
            context,
            bucketHash: args?.bucketHash,
            classType: args?.classType,
            emblemHash: args?.emblemHash,
            idsToAvoid: args?.idsToAvoid,
          ),
        ),
        Provider<ItemInteractionHandlerBloc>(create: (context) {
          final bloc = context.read<SelectLoadoutItemBloc>();
          return ItemInteractionHandlerBloc(
            onTap: (item) => item is InventoryItemInfo ? bloc.onItemTap(item) : null,
            onHold: (item) => item is InventoryItemInfo ? bloc.onItemHold(item) : null,
          );
        }),
      ],
      builder: (context, _) => SelectLoadoutItemView(
        context.read<SelectLoadoutItemBloc>(),
        context.watch<SelectLoadoutItemBloc>(),
      ),
    );
  }
}
