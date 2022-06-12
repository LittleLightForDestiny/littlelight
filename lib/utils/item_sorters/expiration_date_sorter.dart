import 'package:little_light/utils/item_with_owner.dart';

import 'package:little_light/utils/item_sorters/base_item_sorter.dart';

class ExpirationDateSorter extends BaseItemSorter {
  ExpirationDateSorter(int direction) : super(direction);

  int expirationToInt(String? exp) {
    if (exp == null) return 99999999 * direction;
    var date = DateTime.parse(exp);
    if (date.isBefore(DateTime.now())) return 99999998 * direction;
    return date.difference(DateTime.now()).inMinutes;
  }

  @override
  int sort(ItemWithOwner a, ItemWithOwner b) {
    var expA = expirationToInt(a.item.expirationDate);
    var expB = expirationToInt(b.item.expirationDate);
    return expA.compareTo(expB) * direction;
  }
}
