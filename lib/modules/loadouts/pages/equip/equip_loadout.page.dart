import 'package:flutter/material.dart';
import 'equip_loadout.bloc.dart';
import 'equip_loadout.view.dart';

import 'package:provider/provider.dart';

class EquipLoadoutPage extends StatelessWidget {
  final String loadoutId;

  const EquipLoadoutPage(this.loadoutId, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<EquipLoadoutBloc>(
          create: (context) => EquipLoadoutBloc(
            context,
            loadoutId,
          ),
        ),
      ],
      child: EquipLoadoutView(),
    );
  }
}
