import 'package:flutter/material.dart';
import 'package:little_light/modules/equipment/pages/equipment/equipment.bloc.dart';
import 'package:little_light/modules/equipment/pages/equipment/equipment.view.dart';

import 'package:provider/provider.dart';

class EquipmentPage extends StatelessWidget {
  const EquipmentPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<EquipmentBloc>(
          create: (context) => EquipmentBloc(
            context,
          ),
        ),
      ],
      builder: (context, _) => EquipmentView(
        context.read<EquipmentBloc>(),
        context.watch<EquipmentBloc>(),
      ),
    );
  }
}
