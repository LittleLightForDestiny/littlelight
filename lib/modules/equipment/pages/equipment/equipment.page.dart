import 'package:flutter/material.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';
import 'package:little_light/modules/equipment/pages/equipment/equipment.bloc.dart';
import 'package:little_light/modules/equipment/pages/equipment/equipment.view.dart';
import 'package:little_light/shared/blocs/item_interaction_handler/item_interaction_handler.bloc.dart';
import 'package:provider/provider.dart';

class EquipmentPage extends StatelessWidget {
  const EquipmentPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<EquipmentBloc>(create: (context) => EquipmentBloc(context)),
        Provider<ItemInteractionHandlerBloc>(create: (context) {
          final bloc = context.read<EquipmentBloc>();
          return ItemInteractionHandlerBloc(
            onTap: (item) => item is InventoryItemInfo ? bloc.onItemTap(item) : null,
            onHold: (item) => item is InventoryItemInfo ? bloc.onItemHold(item) : null,
            onEmptySlotTap: (bucketHash, characterId) => bloc.openQuickTransfer(bucketHash, characterId),
          );
        }),
      ],
      builder: (context, _) => EquipmentView(
        context.read<EquipmentBloc>(),
        context.watch<EquipmentBloc>(),
      ),
    );
  }
}
