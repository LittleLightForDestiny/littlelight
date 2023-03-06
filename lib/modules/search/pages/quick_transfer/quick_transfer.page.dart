import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/modules/search/blocs/search_filter.bloc.dart';
import 'package:little_light/modules/search/blocs/search_sorter.bloc.dart';

import 'package:little_light/modules/search/pages/quick_transfer/quick_transfer.bloc.dart';
import 'package:little_light/modules/search/pages/quick_transfer/quick_transfer.page_route.dart';
import 'package:little_light/modules/search/pages/quick_transfer/quick_transfer.view.dart';
import 'package:little_light/shared/blocs/item_interaction_handler/item_interaction_handler.bloc.dart';
import 'package:provider/provider.dart';

class QuickTransferPage extends StatelessWidget {
  const QuickTransferPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = QuickTransferPageRouteArguments.of(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SearchFilterBloc(context)),
        ChangeNotifierProvider<SearchSorterBloc>(create: (context) {
          final activeSorters =
              context.read<UserSettingsBloc>().itemOrdering?.where((s) => s.active).toList() ?? <ItemSortParameter>[];
          return SearchSorterBloc(context, activeSorters: activeSorters);
        }),
        ChangeNotifierProvider(
          create: (context) => QuickTransferBloc(
            context,
            bucketHash: args?.bucketHash,
            characterId: args?.characterId,
          ),
        ),
        Provider<ItemInteractionHandlerBloc>(create: (context) {
          final bloc = context.read<QuickTransferBloc>();
          return ItemInteractionHandlerBloc(
            onTap: (item) => bloc.onItemTap(item),
            onHold: (item) => bloc.onItemHold(item),
          );
        }),
      ],
      builder: (context, _) => QuickTransferView(
        context.read<QuickTransferBloc>(),
        context.watch<QuickTransferBloc>(),
      ),
    );
  }
}
