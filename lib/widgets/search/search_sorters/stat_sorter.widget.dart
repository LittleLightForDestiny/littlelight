import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/dialogs/select_stat.dialog.dart';
import 'package:little_light/widgets/search/search.controller.dart';
import 'package:little_light/widgets/search/search_sorters/base_search_sorter.widget.dart';

class StatSorterWidget extends BaseSearchSorterWidget {
  StatSorterWidget(SearchController controller, ItemSortParameter sortParameter, {Widget handle})
      : super(controller, sortParameter, handle: handle);

  @override
  StatSorterWidgetState createState() => StatSorterWidgetState();
}

class StatSorterWidgetState extends BaseSearchSorterWidgetState<StatSorterWidget> with ProfileConsumer {
  @override
  addSorter(BuildContext context) async {
    List<int> statHashes = [];
    controller.filtered.forEach((element) {
      var stats = profile.getPrecalculatedStats(element?.item?.itemInstanceId) ?? Map();
      statHashes.addAll(stats.keys.map((k) => int.parse(k)));
    });
    statHashes = statHashes.toSet().toList();
    final selectedStat = await Navigator.of(context).push(SelectStatDialogRoute(context, statHashes));
    if (selectedStat == null) return;
    controller.customSorting.insert(
        0, ItemSortParameter(active: true, type: this.sortParameter.type, customData: {"statHash": selectedStat}));
    controller.sort();
  }

  int get statHash => (this.sortParameter.customData ?? const {})['statHash'];

  Widget buildSortLabel(BuildContext context) {
    var style = TextStyle(
        fontWeight: FontWeight.bold,
        color: sortParameter.active ? Theme.of(context).colorScheme.onSurface : Colors.grey.shade300);
    if (statHash != null) {
      return ManifestText<DestinyStatDefinition>(statHash, uppercase: true, style: style);
    }
    return super.buildSortLabel(context);
  }
}
