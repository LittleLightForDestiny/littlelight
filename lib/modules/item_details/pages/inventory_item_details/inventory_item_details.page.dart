import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/modules/item_details/blocs/inventory_item_socket_controller.bloc.dart';
import 'package:little_light/modules/item_details/blocs/socket_controller.bloc.dart';
import 'package:little_light/modules/item_details/pages/inventory_item_details/inventory_item_details.bloc.dart';
import 'package:little_light/modules/item_details/pages/inventory_item_details/inventory_item_details.view.dart';
import 'package:provider/provider.dart';

class InventoryItemDetailsPage extends StatelessWidget {
  final DestinyItemInfo item;

  const InventoryItemDetailsPage(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SocketControllerBloc>(create: (context) => InventoryItemSocketControllerBloc(context)),
        ChangeNotifierProvider(create: (context) => InventoryItemDetailsBloc(context, item: item)),
      ],
      builder: (context, _) => InventoryItemDetailsView(
        context.read<InventoryItemDetailsBloc>(),
        context.watch<InventoryItemDetailsBloc>(),
        context.watch<SocketControllerBloc>(),
      ),
    );
  }
}
