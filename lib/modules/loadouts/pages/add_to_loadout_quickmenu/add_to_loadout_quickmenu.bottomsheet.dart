import 'package:flutter/material.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';
import 'package:little_light/modules/loadouts/pages/loadout_item_options/loadout_item_options_socket_controller.bloc.dart';
import 'package:little_light/shared/blocs/scoped_value_repository/scoped_value_repository.bloc.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:little_light/shared/widgets/modals/base_bottom_sheet.base.dart';
import 'package:provider/provider.dart';

import 'add_to_loadout_quickmenu.bloc.dart';
import 'add_to_loadout_quickmenu.view.dart';

class AddToLoadoutBottomsheet extends BaseBottomSheet<void> {
  final InventoryItemInfo item;
  AddToLoadoutBottomsheet(this.item);

  @override
  Widget buildContainer(BuildContext context, BuildCallback builder) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<ScopedValueRepositoryBloc>(create: (context) => ScopedValueRepositoryBloc()),
      ChangeNotifierProvider<SocketControllerBloc>(
          create: (context) => LoadoutItemOptionsSocketControllerBloc(context)),
      ChangeNotifierProvider(create: (context) => AddToLoadoutQuickmenuBloc(context, item)),
    ], builder: (context, child) => builder(context));
  }

  @override
  Widget? buildHeader(BuildContext context) => null;

  @override
  Widget buildContent(BuildContext context) {
    return AddToLoadoutQuickMenuView(
      bloc: context.read<AddToLoadoutQuickmenuBloc>(),
      state: context.watch<AddToLoadoutQuickmenuBloc>(),
    );
  }

  @override
  Future<void> show(BuildContext context) {
    return showModalBottomSheet(context: context, builder: (context) => this, isScrollControlled: true);
  }
}
