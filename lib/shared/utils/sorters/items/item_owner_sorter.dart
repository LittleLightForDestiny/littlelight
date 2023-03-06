import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';

import 'item_sorter.dart';

class ItemOwnerSorter extends ItemSorter {
  List<DestinyCharacterInfo> characters;

  ItemOwnerSorter(
    BuildContext context,
    SorterDirection direction,
    this.characters,
  ) : super(context, direction);

  @override
  int sort(DestinyItemInfo a, DestinyItemInfo b) {
    int orderA = characters.indexWhere((c) => c.characterId == a.characterId);
    int orderB = characters.indexWhere((c) => c.characterId == b.characterId);
    if (orderA < 0) orderA = 9999;
    if (orderB < 0) orderB = 9999;
    return (orderA.compareTo(orderB) * direction.asInt).toInt();
  }
}
