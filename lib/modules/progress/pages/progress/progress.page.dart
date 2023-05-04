import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';
import 'package:little_light/modules/progress/pages/progress/milestones.bloc.dart';
import 'package:little_light/modules/progress/pages/progress/progress.bloc.dart';
import 'package:little_light/shared/blocs/bucket_options/bucket_options.bloc.dart';
import 'package:little_light/shared/blocs/item_interaction_handler/item_interaction_handler.bloc.dart';
import 'package:little_light/shared/blocs/scoped_value_repository/scoped_value_repository.bloc.dart';
import 'package:provider/provider.dart';

import 'progress.view.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ItemSectionOptionsBloc>(create: (context) => ItemSectionOptionsBloc(context)),
        ChangeNotifierProvider<ScopedValueRepositoryBloc>(create: (context) => ScopedValueRepositoryBloc()),
        ChangeNotifierProvider(create: (context) => MilestonesBloc(context)),
        ChangeNotifierProvider(create: (context) => ProgressBloc(context)),
        Provider<ItemInteractionHandlerBloc>(create: (context) {
          final bloc = context.read<ProgressBloc>();
          return ItemInteractionHandlerBloc(
            onTap: (item) => item is InventoryItemInfo ? bloc.onItemTap(item) : null,
            onHold: (item) => item is InventoryItemInfo ? bloc.onItemHold(item) : null,
            onEmptySlotTap: (bucketHash, characterId) => bloc.openSearch(bucketHash, characterId),
          );
        }),
      ],
      builder: (context, _) => ProgressView(
        context.read<ProgressBloc>(),
        context.watch<ProgressBloc>(),
        context.watch<MilestonesBloc>(),
      ),
    );
  }
}
