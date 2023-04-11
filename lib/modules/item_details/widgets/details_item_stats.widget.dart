import 'package:flutter/material.dart';

const _sectionId = "item_stats";

class DetailsItemStatsWidget extends StatelessWidget {
  const DetailsItemStatsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
    // if (stats == null) return Container();
    // super.build(context);
    // return Container(
    //   padding: const EdgeInsets.all(8),
    //   child: Column(
    //     children: <Widget>[
    //       buildHeader(context),
    //       visible
    //           ? Container(
    //               constraints: const BoxConstraints.tightFor(width: 600),
    //               padding: const EdgeInsets.symmetric(vertical: 8),
    //               child: Column(children: buildStats(context)))
    //           : Container(),
    //     ],
    //   ),
    // );
  }

  @override
  Widget buildHeader(BuildContext context) {
    return Container();
    // return getHeader(
    //   TranslatedTextWidget(
    //     "Stats",
    //     uppercase: true,
    //     textAlign: TextAlign.left,
    //     style: const TextStyle(fontWeight: FontWeight.bold),
    //   ),
    // );
  }

  @override
  List<Widget> buildStats(context) {
    return [];
    //   Map<int, StatValues> statValues = getStatValues();

    //   StatValues totalStat;
    //   if (definition.itemType == DestinyItemType.Armor) {
    //     totalStat = StatValues();
    //     for (var stat in stats) {
    //       var entry = statValues[stat.statTypeHash];
    //       totalStat.equipped += entry?.equipped ?? 0;
    //       totalStat.selected += entry?.selected ?? 0;
    //       totalStat.masterwork += entry?.masterwork ?? 0;
    //     }
    //   }
    //   return stats
    //       .map((stat) {
    //         if (statValues == null) return Container();
    //         var entry = statValues[stat.statTypeHash];
    //         return DetailsItemStatWidget(
    //           statHash: stat.statTypeHash,
    //           modValues: entry,
    //           scaled:
    //               statGroupDefinition.scaledStats.firstWhere((s) => s.statHash == stat.statTypeHash, orElse: () => null),
    //         );
    //       })
    //       .followedBy(totalStat == null ? [] : [DetailsTotalStatWidget(modValues: totalStat)])
    //       .toList();
  }
}
