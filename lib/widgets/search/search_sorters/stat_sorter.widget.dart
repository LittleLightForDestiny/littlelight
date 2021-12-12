import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

import 'package:little_light/widgets/search/search.controller.dart';
import 'package:little_light/widgets/search/search_sorters/base_search_sorter.widget.dart';

class StatSorterWidget extends BaseSearchSorterWidget {
  StatSorterWidget(SearchController controller, ItemSortParameter sortParameter,
      {Widget handle})
      : super(controller, sortParameter, handle: handle);

  @override
  StatSorterWidgetState createState() => StatSorterWidgetState();
}

class StatSorterWidgetState
    extends BaseSearchSorterWidgetState<StatSorterWidget> {
  @override
  addSorter(BuildContext context) async {
    List<int> statHashes = [];
    controller.filtered.forEach((element) {
      var stats = ProfileService()
              .getPrecalculatedStats(element?.item?.itemInstanceId) ??
          Map();
      statHashes.addAll(stats.keys.map((k) => int.parse(k)));
    });
    statHashes = statHashes.toSet().toList();
    var selectedStat = await showDialog(
        context: context,
        builder: (BuildContext context) {
          var dialog = SimpleDialog(
            title: TranslatedTextWidget("Select Stat"),
            children: <Widget>[
              Container(
                  height: MediaQuery.of(context).size.height - 100,
                  width: MediaQuery.of(context).size.width - 100,
                  child: ListView.builder(
                      itemCount: statHashes.length,
                      itemBuilder: (BuildContext context, int index) {
                        var statHash = statHashes[index];
                        return Container(
                            padding: EdgeInsets.all(4).copyWith(top: 0),
                            child: Material(
                                color: Colors.blueGrey,
                                child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).pop(statHash);
                                    },
                                    child: Container(
                                        padding: EdgeInsets.all(8),
                                        alignment: Alignment.centerLeft,
                                        height: 48,
                                        child:
                                            ManifestText<DestinyStatDefinition>(
                                                statHash)))));
                      }))
            ],
          );
          return dialog;
        });
    if (selectedStat == null) return;
    controller.customSorting.insert(
        0,
        ItemSortParameter(
            active: true,
            type: this.sortParameter.type,
            customData: {"statHash": selectedStat}));
    controller.sort();
  }

  int get statHash => (this.sortParameter.customData ?? const {})['statHash'];

  Widget buildSortLabel(BuildContext context) {
    var style = TextStyle(
        fontWeight: FontWeight.bold,
        color: sortParameter.active ? Colors.white : Colors.grey.shade300);
    if (statHash != null) {
      return ManifestText<DestinyStatDefinition>(statHash,
          uppercase: true, style: style);
    }
    return super.buildSortLabel(context);
  }
}
