import 'package:bungie_api/destiny2.dart';
import 'package:little_light/shared/utils/helpers/loadout_helpers.dart';

import 'loadout_item_info.dart';

class LoadoutIndexSlot {
  LoadoutItemInfo genericEquipped = LoadoutItemInfo();
  Map<DestinyClass, LoadoutItemInfo> classSpecificEquipped = {};
  List<LoadoutItemInfo> unequipped = [];

  LoadoutIndexSlot();
}

class LoadoutItemIndex {
  final int? emblemHash;
  final String? loadoutId;
  final String name;

  Map<int, LoadoutIndexSlot> slots = {
    for (var e in loadoutGenericBucketHashes + loadoutClassSpecificBucketHashes) e: LoadoutIndexSlot()
  };

  LoadoutItemIndex(this.name, {this.loadoutId, this.emblemHash});

  static List<int> get genericBucketHashes => loadoutGenericBucketHashes;
  static List<int> get classSpecificBucketHashes => loadoutClassSpecificBucketHashes;
}
