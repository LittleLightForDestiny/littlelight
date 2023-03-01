import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/modules/search/blocs/filter_adapter.bloc.dart';
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
        ChangeNotifierProvider(
          create: (context) => QuickTransferBloc(
            context,
            bucketHash: args?.bucketHash,
            characterId: args?.characterId,
          ),
        ),
        ChangeNotifierProvider<FilterAdapterBloc>(create: (context) {
          final bloc = context.read<QuickTransferBloc>();
          return FilterAdapterBloc(
            bloc.filters,
            onChangeSetValue: bloc.updateFilterSetValue,
            onUpdateFilterValue: bloc.updateFilterValue,
            onUpdateFilterEnabledStatus: bloc.updateFilterEnabledStatus,
          );
        }),
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
