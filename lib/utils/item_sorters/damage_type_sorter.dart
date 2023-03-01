import 'package:bungie_api/enums/damage_type.dart';
import 'package:little_light/utils/item_sorters/base_item_sorter.dart';
import 'package:little_light/utils/item_with_owner.dart';

class DamageTypeSorter extends BaseItemSorter {
  DamageTypeSorter(int direction) : super(direction);

  @override
  int sort(ItemWithOwner a, ItemWithOwner b) {
    var instanceA = instance(a);
    var instanceB = instance(b);
    return instanceA?.damageType?.value
            ?.compareTo(instanceB?.damageType?.value ?? 0) ??
        0;
  }
}
