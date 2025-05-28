import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'create_destiny_loadout_from_equipped.bloc.dart';
import 'create_destiny_loadout_from_equipped.view.dart';

class CreateDestinyLoadoutFromEquippedPage extends StatelessWidget {
  final String characterId;
  final int loadoutIndex;
  const CreateDestinyLoadoutFromEquippedPage({
    super.key,
    required this.characterId,
    required this.loadoutIndex,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => CreateDestinyLoadoutFromEquippedBloc(
                  context,
                  characterId: characterId,
                  loadoutIndex: loadoutIndex,
                ))
      ],
      builder: (context, _) => CreateDestinyLoadoutFromEquippedView(
        bloc: context.read<CreateDestinyLoadoutFromEquippedBloc>(),
        state: context.watch<CreateDestinyLoadoutFromEquippedBloc>(),
      ),
    );
  }
}
