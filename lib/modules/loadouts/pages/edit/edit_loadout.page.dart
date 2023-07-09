import 'package:flutter/material.dart';
import 'package:little_light/models/loadout.dart';
import 'package:provider/provider.dart';

import 'edit_loadout.bloc.dart';
import 'edit_loadout.view.dart';

class EditLoadoutPage extends StatelessWidget {
  final String? loadoutID;
  final Loadout? preset;

  const EditLoadoutPage({
    this.loadoutID,
    this.preset,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => EditLoadoutBloc(context, loadoutID: loadoutID, preset: preset)),
      ],
      builder: (context, _) => EditLoadoutView(context.read<EditLoadoutBloc>(), context.watch<EditLoadoutBloc>()),
    );
  }
}
