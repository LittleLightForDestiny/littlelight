import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'item_sorter.dart';

class MultiSorter {
  bool isPrepared = false;
  final List<ItemSorter> _sorters;
  MultiSorter(this._sorters);

  Future<List<T>> sort<T extends DestinyItemInfo>(List<T> items) async {
    final toSort = items.toList(growable: false);
    if (_sorters.isEmpty) return toSort;
    if (!isPrepared) {
      await Future.wait(_sorters.map((s) => s.prepare(toSort)));
      isPrepared = true;
    }
    toSort.sort((a, b) {
      for (final sorter in _sorters) {
        final res = sorter.sort(a, b);
        if (res != 0) return res;
      }
      final originalIndexA = items.indexOf(a);
      final originalIndexB = items.indexOf(b);
      return originalIndexA.compareTo(originalIndexB);
    });
    return toSort;
  }
}
