import 'package:flutter/material.dart';

import 'destiny_loadout_details.page.dart';

class DestinyLoadoutDetailsPageRoute extends MaterialPageRoute {
  DestinyLoadoutDetailsPageRoute({
    required String characterId,
    required int loadoutIndex,
  }) : super(
          builder: (BuildContext context) =>
              DestinyLoadoutDetailsPage(characterId: characterId, loadoutIndex: loadoutIndex),
        );
}
