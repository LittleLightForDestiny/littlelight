import 'package:bungie_api/models/destiny_stat.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/item_sorters/base_item_sorter.dart';
import 'package:little_light/utils/item_with_owner.dart';

class StatSorter extends BaseItemSorter {
  Map<String, dynamic> data;
  StatSorter(int direction, this.data) : super(direction);

  int get statHash => data['statHash'];

  @override
  int sort(ItemWithOwner a, ItemWithOwner b) {
    Map<String, DestinyStat> statsA =
        ProfileService().getPrecalculatedStats(a.item.itemInstanceId);
    Map<String, DestinyStat> statsB =
        ProfileService().getPrecalculatedStats(b.item.itemInstanceId);
    int totalA = (statsA ?? const {})["$statHash"]?.value ?? 0;
    int totalB = (statsB ?? const {})["$statHash"]?.value ?? 0;
    return direction * totalA.compareTo(totalB);
  }

}
