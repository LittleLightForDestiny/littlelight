import 'package:flutter/material.dart';
import 'package:little_light/modules/loadouts/pages/edit_item_mods/edit_loadout_item_mods.bloc.dart';
import 'package:little_light/modules/loadouts/pages/edit_item_mods/edit_loadout_item_mods.view.dart';
import 'package:provider/provider.dart';

import 'edit_loadout_item_mods.page_route.dart';

class EditLoadoutItemModsPage extends StatelessWidget {
  final EditLoadoutItemModsPageArguments args;

  const EditLoadoutItemModsPage(this.args, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: args),
        ChangeNotifierProvider(create: (context) => EditLoadoutItemModsBloc(context))
      ],
      child: EditLoadoutItemModsView(),
    );
  }
}
