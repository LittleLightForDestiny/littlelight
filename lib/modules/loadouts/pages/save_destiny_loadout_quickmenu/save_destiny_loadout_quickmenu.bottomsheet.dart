import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/shared/blocs/scoped_value_repository/scoped_value_repository.bloc.dart';
import 'package:little_light/shared/widgets/modals/base_bottom_sheet.base.dart';
import 'package:provider/provider.dart';

import 'save_destiny_loadout_quickmenu.bloc.dart';
import 'save_destiny_loadout_quickmenu.view.dart';

class SaveDestinyLoadoutBottomsheet extends BaseBottomSheet<void> {
  final DestinyCharacterInfo character;
  SaveDestinyLoadoutBottomsheet(this.character);

  @override
  Widget buildContainer(BuildContext context, BuildCallback builder) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<ScopedValueRepositoryBloc>(create: (context) => ScopedValueRepositoryBloc()),
      ChangeNotifierProvider(create: (context) => SaveDestinyLoadoutQuickmenuBloc(context, character)),
    ], builder: (context, child) => builder(context));
  }

  @override
  Widget? buildHeader(BuildContext context) => null;

  @override
  Widget buildContent(BuildContext context) {
    return SaveDestinyLoadoutQuickmenuView(
      bloc: context.read<SaveDestinyLoadoutQuickmenuBloc>(),
      state: context.watch<SaveDestinyLoadoutQuickmenuBloc>(),
    );
  }

  @override
  Future<void> show(BuildContext context) {
    return showModalBottomSheet(context: context, builder: (context) => this, isScrollControlled: true);
  }
}
