import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/modules/equipment/pages/equipment/equipment.bloc.dart';
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
        ChangeNotifierProvider<BucketOptionsBloc>(create: (context) => BucketOptionsBloc(context)),
        ChangeNotifierProvider<ScopedValueRepositoryBloc>(create: (context) => ScopedValueRepositoryBloc()),
        ChangeNotifierProvider(create: (context) => MilestonesBloc(context)),
        ChangeNotifierProvider(create: (context) => ProgressBloc(context)),
        Provider<ItemInteractionHandlerBloc>(create: (context) {
          final bloc = context.read<EquipmentBloc>();
          return ItemInteractionHandlerBloc(
            onTap: (item) => bloc.onItemTap(item),
            onHold: (item) => bloc.onItemHold(item),
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
