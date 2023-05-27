import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/loadouts/loadout_item_info.dart';
import 'package:little_light/modules/loadouts/pages/loadout_item_options/loadout_item_options_socket_controller.bloc.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:little_light/shared/widgets/modals/base_bottom_sheet.base.dart';
import 'package:provider/provider.dart';

import 'loadout_item_options.bloc.dart';
import 'loadout_item_options.view.dart';

enum LoadoutItemOption {
  Remove,
  EditMods,
}

class LoadoutItemOptionsBottomSheet extends BaseBottomSheet<LoadoutItemOption> {
  final LoadoutItemInfo item;
  LoadoutItemOptionsBottomSheet(this.item);

  @override
  Widget? buildHeader(BuildContext context) {
    return Text("Loadout item options".translate(context).toUpperCase());
  }

  @override
  Widget buildContent(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SocketControllerBloc>(
            create: (context) => LoadoutItemOptionsSocketControllerBloc(context)),
        ChangeNotifierProvider(create: (context) => LoadoutItemOptionsBloc(context, item)),
      ],
      builder: (context, child) => LoadoutItemOptionsView(
        bloc: context.read<LoadoutItemOptionsBloc>(),
        state: context.watch<LoadoutItemOptionsBloc>(),
        socketState: context.watch<SocketControllerBloc>(),
      ),
    );
  }

  @override
  Future<LoadoutItemOption?> show(BuildContext context) {
    return super.show(context);
  }
}
