import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/modules/dev_tools/pages/stats/dev_tools_stats.bloc.dart';
import 'package:little_light/shared/widgets/inventory_item/high_density_inventory_item.dart';
import 'package:little_light/shared/widgets/notifications/notifications.widget.dart';
import 'package:little_light/shared/widgets/ui/switch.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:provider/provider.dart';

class StatsViewItem extends StatelessWidget {
  final StatsItem item;

  StatsViewItem(StatsItem this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      child: Column(
        children: [
          Container(
            height: 96,
            child: HighDensityInventoryItem(item.item),
          ),
          buildStats(context),
        ],
      ),
    );
  }

  Widget buildStats(BuildContext context) {
    final precalculated = item.precalculated;
    return Column(
      children: <Widget>[
            Row(children: [
              Expanded(
                child: Text("Stat"),
                flex: 3,
              ),
              Expanded(child: Text("Precalculated")),
              Expanded(child: Text("Via Plugs"))
            ]),
          ] +
          precalculated.keys.map((key) => buildStat(context, key)).toList(),
    );
  }

  Widget buildStat(BuildContext context, int statHash) {
    final precalculated = item.precalculated[statHash];
    final equipped = item.stats[statHash]?.equipped ?? 0;
    final masterwork = item.stats[statHash]?.equippedMasterwork ?? 0;
    final fromPlugs = equipped + masterwork;
    final hasError = precalculated != fromPlugs;
    return DefaultTextStyle(
        style: TextStyle(color: hasError ? Colors.red : null),
        child: Row(
          children: [
            Expanded(child: ManifestText<DestinyStatDefinition>(statHash), flex: 3),
            Expanded(child: Text("$precalculated")),
            Expanded(child: Text("$fromPlugs")),
          ],
        ));
  }
}

class DevToolsStatsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<DevToolsStatsBloc>();
    return Scaffold(
      appBar: AppBar(
        title: Text("Dev Tools Stats"),
        actions: [
          Container(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Text("Only with Issues"),
                  Container(
                    width: 4,
                  ),
                  LLSwitch.callback(state.onlyWithIssues, (p0) {
                    context.read<DevToolsStatsBloc>().onlyWithIssues = p0;
                  })
                ],
              )),
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: state.items?.length,
            itemBuilder: (context, index) {
              final item = state.items?[index];
              if (item == null) return null;
              return StatsViewItem(item);
            },
          ),
          Positioned(bottom: 8, left: 8, right: 8, child: NotificationsWidget()),
        ],
      ),
    );
  }
}
