import 'package:flutter/material.dart';
import 'package:little_light/modules/loadouts/pages/equip/equip_loadout.page_route.dart';
import 'equip_loadout.bloc.dart';
import 'equip_loadout.view.dart';

import 'package:provider/provider.dart';

class EquipLoadoutPage extends StatelessWidget {
  final EquipLoadoutPageRouteArguments args;

  const EquipLoadoutPage(this.args, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<EquipLoadoutPageRouteArguments>.value(value: args),
        ChangeNotifierProvider<EquipLoadoutBloc>(
          create: (context) => EquipLoadoutBloc(
            context,
          ),
        ),
      ],
      child: EquipLoadoutView(),
    );
  }
}
