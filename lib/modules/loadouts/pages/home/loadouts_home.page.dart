import 'package:flutter/material.dart';
import 'package:little_light/modules/loadouts/pages/home/destiny_loadouts.bloc.dart';
import 'package:provider/provider.dart';
import 'little_light_loadouts.bloc.dart';
import 'loadouts_home.view.dart';

class LoadoutsHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LittleLightLoadoutsBloc(
            context,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => DestinyLoadoutsBloc(
            context,
          ),
        ),
      ],
      builder: (context, child) => LoadoutsHomeView(
        littleLightLoadoutsBloc: context.read<LittleLightLoadoutsBloc>(),
        littlelightLoadoutsState: context.watch<LittleLightLoadoutsBloc>(),
        destinyLoadoutsBloc: context.read<DestinyLoadoutsBloc>(),
        destinyLoadoutsState: context.watch<DestinyLoadoutsBloc>(),
      ),
    );
  }
}
