import 'package:flutter/material.dart';
import 'package:little_light/modules/loadouts/pages/edit/edit_loadout.bloc.dart';
import 'package:little_light/modules/loadouts/pages/edit/edit_loadout.view.dart';
import 'package:provider/provider.dart';

class EditLoadoutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => EditLoadoutBloc(context)),
      ],
      child: EditLoadoutView(),
    );
  }
}
