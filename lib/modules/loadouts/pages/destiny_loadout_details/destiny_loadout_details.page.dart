import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'destiny_loadout_details.bloc.dart';
import 'destiny_loadout_details.view.dart';

class DestinyLoadoutDetailsPage extends StatelessWidget {
  final String characterId;
  final int loadoutIndex;
  const DestinyLoadoutDetailsPage({
    super.key,
    required this.characterId,
    required this.loadoutIndex,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => DestinyLoadoutDetailsBloc(
                  context,
                  characterId: characterId,
                  loadoutIndex: loadoutIndex,
                ))
      ],
      builder: (context, _) => DestinyLoadoutDetailsView(
        bloc: context.read<DestinyLoadoutDetailsBloc>(),
        state: context.watch<DestinyLoadoutDetailsBloc>(),
      ),
    );
  }
}
