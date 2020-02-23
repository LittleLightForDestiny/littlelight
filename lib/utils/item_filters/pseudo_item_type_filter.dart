import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/utils/item_with_owner.dart';

import 'base_item_filter.dart';

enum PseudoItemType{
  Weapons,
  Armor,
  Cosmetics, 
  Pursuits,
  Consumables
}

class PseudoItemTypeFilter extends BaseItemFilter<Set<PseudoItemType>> {
  PseudoItemTypeFilter(Iterable<PseudoItemType> available, Iterable<PseudoItemType>value) : super(available?.toSet(), value?.toSet(), enabled:true);

  bool filterItem(ItemWithOwner item,
      {Map<int, DestinyInventoryItemDefinition> definitions}) {
    if((value?.length ?? 0) < 1) return true;
    var def = definitions[item?.item?.itemHash];
    var bucketHash = def?.inventory?.bucketTypeHash;
    if(value.contains(PseudoItemType.Weapons) && InventoryBucket.weaponBucketHashes.contains(bucketHash)) return true;
    if(value.contains(PseudoItemType.Armor) && InventoryBucket.armorBucketHashes.contains(bucketHash)) return true;
    if(value.contains(PseudoItemType.Cosmetics) && InventoryBucket.flairBucketHashes.contains(bucketHash)) return true;
    if(value.contains(PseudoItemType.Pursuits) && InventoryBucket.pursuitBucketHashes.contains(bucketHash)) return true;
    if(value.contains(PseudoItemType.Consumables) && InventoryBucket.inventoryBucketHashes.contains(bucketHash)) return true;
    return false;
  }
}
