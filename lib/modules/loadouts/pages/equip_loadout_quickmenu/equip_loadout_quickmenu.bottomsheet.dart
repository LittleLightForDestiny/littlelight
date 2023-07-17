import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/modules/loadouts/pages/loadout_item_options/loadout_item_options_socket_controller.bloc.dart';
import 'package:little_light/shared/blocs/scoped_value_repository/scoped_value_repository.bloc.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:little_light/shared/widgets/modals/base_bottom_sheet.base.dart';
import 'package:provider/provider.dart';

import 'equip_loadout_quickmenu.bloc.dart';
import 'equip_loadout_quickmenu.view.dart';

class EquipLoadoutBottomsheet extends BaseBottomSheet<void> {
  final DestinyCharacterInfo character;
  final bool equip;
  EquipLoadoutBottomsheet(this.character, this.equip);

  @override
  Widget buildContainer(BuildContext context, BuildCallback builder) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<ScopedValueRepositoryBloc>(create: (context) => ScopedValueRepositoryBloc()),
      ChangeNotifierProvider<SocketControllerBloc>(
          create: (context) => LoadoutItemOptionsSocketControllerBloc(context)),
      ChangeNotifierProvider(create: (context) => EquipLoadoutQuickmenuBloc(context, character, equip)),
    ], builder: (context, child) => builder(context));
  }

  @override
  Widget? buildHeader(BuildContext context) => null;

  @override
  Widget buildContent(BuildContext context) {
    return EquipLoadoutQuickmenuView(
      bloc: context.read<EquipLoadoutQuickmenuBloc>(),
      state: context.watch<EquipLoadoutQuickmenuBloc>(),
    );
  }

  @override
  Future<void> show(BuildContext context) {
    return showModalBottomSheet(context: context, builder: (context) => this, isScrollControlled: true);
  }
}
