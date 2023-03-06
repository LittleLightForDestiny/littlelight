import 'package:bungie_api/models/destiny_stat.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/utils/item_sorters/base_item_sorter.dart';
import 'package:little_light/utils/item_with_owner.dart';

class StatSorter extends BaseItemSorter with ProfileConsumer {
  Map<String, dynamic>? data;
  StatSorter(SorterDirection direction, this.data) : super(direction);

  int get statHash => data?['statHash'];

  @override
  int sort(ItemWithOwner a, ItemWithOwner b) {
    final instanceIdA = a.item.itemInstanceId;
    final instanceIdB = b.item.itemInstanceId;
    Map<String, DestinyStat>? statsA = instanceIdA != null ? profile.getPrecalculatedStats(instanceIdA) : null;
    Map<String, DestinyStat>? statsB = instanceIdB != null ? profile.getPrecalculatedStats(instanceIdB) : null;
    int totalA = statsA?["$statHash"]?.value ?? 0;
    int totalB = statsB?["$statHash"]?.value ?? 0;
    return direction.asInt * totalA.compareTo(totalB);
  }
}
