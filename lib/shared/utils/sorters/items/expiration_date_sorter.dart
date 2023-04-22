import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';

import 'item_sorter.dart';

class ExpirationDateSorter extends ItemSorter {
  ExpirationDateSorter(BuildContext context, SorterDirection direction) : super(context, direction);

  int expirationToInt(String? exp) {
    if (exp == null) return 99999999 * direction.asInt;
    var date = DateTime.parse(exp);
    if (date.isBefore(DateTime.now())) return 99999998 * direction.asInt;
    return date.difference(DateTime.now()).inMinutes;
  }

  @override
  int sort(DestinyItemInfo a, DestinyItemInfo b) {
    final expA = expirationToInt(a.expirationDate);
    final expB = expirationToInt(b.expirationDate);
    return expA.compareTo(expB) * direction.asInt;
  }
}
