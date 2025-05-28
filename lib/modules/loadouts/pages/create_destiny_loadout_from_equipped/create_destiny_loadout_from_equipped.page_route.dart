import 'package:flutter/material.dart';

import 'create_destiny_loadout_from_equipped.page.dart';

class CreateDestinyLoadoutFromEquippedPageRoute extends MaterialPageRoute {
  CreateDestinyLoadoutFromEquippedPageRoute({
    required String characterId,
    required int loadoutIndex,
  }) : super(
          builder: (BuildContext context) =>
              CreateDestinyLoadoutFromEquippedPage(characterId: characterId, loadoutIndex: loadoutIndex),
        );
}
