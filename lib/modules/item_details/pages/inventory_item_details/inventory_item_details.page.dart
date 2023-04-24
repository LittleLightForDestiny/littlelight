import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/core/blocs/selection/selection.bloc.dart';
import 'package:little_light/modules/item_details/blocs/item_details.bloc.dart';
import 'package:little_light/modules/item_details/pages/inventory_item_details/inventory_item_details.bloc.dart';
import 'package:little_light/modules/item_details/pages/inventory_item_details/inventory_item_details.view.dart';
import 'package:little_light/modules/item_details/pages/inventory_item_details/inventory_item_socket_controller.bloc.dart';
import 'package:little_light/shared/blocs/item_interaction_handler/item_interaction_handler.bloc.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:provider/provider.dart';

class InventoryItemDetailsPage extends StatelessWidget {
  final DestinyItemInfo item;

  const InventoryItemDetailsPage(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SocketControllerBloc>(create: (context) => InventoryItemSocketControllerBloc(context)),
        ChangeNotifierProvider<ItemDetailsBloc>(create: (context) => InventoryItemDetailsBloc(context, item: item)),
        Provider<ItemInteractionHandlerBloc>(create: (context) {
          final bloc = context.read<ItemDetailsBloc>();
          return ItemInteractionHandlerBloc(
            onTap: (item) => bloc.onDuplicateItemTap(item),
            onHold: (item) => bloc.onDuplicateItemHold(item),
          );
        }),
      ],
      builder: (context, _) => InventoryItemDetailsView(
        context.read<ItemDetailsBloc>(),
        context.watch<ItemDetailsBloc>(),
        context.watch<SocketControllerBloc>(),
        context.watch<SelectionBloc>(),
      ),
    );
  }
}
