import 'package:flutter/material.dart';
import 'package:little_light/modules/loadouts/pages/edit/edit_loadout.bloc.dart';
import 'package:little_light/modules/loadouts/pages/edit/edit_loadout.page_route.dart';
import 'package:little_light/modules/loadouts/pages/edit/edit_loadout.view.dart';
import 'package:provider/provider.dart';

class EditLoadoutPage extends StatelessWidget {
  final EditLoadoutPageRouteArguments args;

  EditLoadoutPage(this.args);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: this.args),
        ChangeNotifierProvider(create: (context) => EditLoadoutBloc(context)),
      ],
      child: EditLoadoutView(),
    );
  }
}
