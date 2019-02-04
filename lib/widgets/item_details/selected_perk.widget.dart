import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_investment_stat_definition.dart';
import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/item_details/item_stats.widget.dart';

class SelectedPerkWidget extends StatelessWidget {
  final int hash;
  SelectedPerkWidget(this.hash, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (hash == null) return Container();
    return DefinitionProviderWidget<DestinyInventoryItemDefinition>(hash,
        (definition) {
      double width = MediaQuery.of(context).size.width;
      List<DestinyItemInvestmentStatDefinition> stats =
          definition.investmentStats;
      return Container(
          margin: EdgeInsets.only(left: 8, right: 8, bottom: 8),
          color: Colors.blueGrey.shade700,
          width: width,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
                color: Colors.black,
                padding: EdgeInsets.all(8),
                child: Text(
                  definition.displayProperties.name.toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
            Row(mainAxisSize: MainAxisSize.max, children: [
              Container(
                width: 72,
                child:
                    ManifestImageWidget<DestinyInventoryItemDefinition>(hash),
              ),
              Expanded(
                  child: Container(
                padding: EdgeInsets.all(8),
                child: Text(
                  definition.displayProperties.description,
                  softWrap: true,
                ),
              ))
            ]),
            buildStats(context, stats)
          ]));
    });
  }

  buildStats(
      BuildContext context, List<DestinyItemInvestmentStatDefinition> stats) {
    if (stats == null || stats.length == 0) {
      return Container();
    }

    List<Widget> statList = stats.map<Widget>((stat) {
      var values = StatValues();
      values.selected = stat.value;
      return ItemStatWidget(stat.statTypeHash, 0, values);
    }).toList();
    return Container(
        color: Colors.blueGrey.shade900,
        margin: EdgeInsets.all(4),
        child: Column(children: [
          Container(
            constraints: BoxConstraints(minWidth: double.infinity),
            color:Colors.black,
            alignment: Alignment.center,
            padding: EdgeInsets.all(4),
            child: TranslatedTextWidget("Stats",
                uppercase: true,
                style: TextStyle(fontWeight: FontWeight.w700))),
          Container(
            padding: EdgeInsets.all(8),
            child:Column(children: statList,)
          )
        ]));
  }
}
