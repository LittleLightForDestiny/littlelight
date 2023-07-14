import 'package:flutter/material.dart';
import 'package:little_light/modules/loadouts/pages/select_background/select_loadout_background.bloc.dart';
import 'select_loadout_background.view.dart';
import 'package:provider/provider.dart';

class SelectLoadoutBackgroundPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => SelectLoadoutBackgroundBloc(context)),
      ],
      child: const SelectLoadoutBackgroundView(),
    );
  }
}
