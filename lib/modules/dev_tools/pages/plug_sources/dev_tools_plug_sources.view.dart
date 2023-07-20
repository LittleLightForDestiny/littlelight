import 'package:flutter/material.dart';
import 'package:little_light/modules/dev_tools/pages/plug_sources/dev_tools_plug_sources.bloc.dart';
import 'package:little_light/shared/widgets/inventory_item/high_density_inventory_item.dart';
import 'package:little_light/shared/widgets/notifications/notifications.widget.dart';
import 'package:little_light/shared/widgets/sockets/perk_icon.widget.dart';
import 'package:little_light/shared/widgets/ui/switch.dart';
import 'package:provider/provider.dart';

class DevToolsPlugSourcesViewItem extends StatelessWidget {
  final DevToolsPlugSourcesItem item;

  DevToolsPlugSourcesViewItem(this.item);

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
          buildSockets(context)
        ],
      ),
    );
  }

  Widget buildSockets(BuildContext context) {
    final issues = item.socketsWithWrongPlugSources;
    if (issues.length == 0) return Container();
    return Column(
      children: issues.map((i) => buildSocket(context, i)).toList(),
    );
  }

  Widget buildSocket(BuildContext context, int index) {
    final plugs = item.item.reusablePlugs?["$index"];
    if (plugs == null || plugs.isEmpty) return Container();
    return Row(
      children: plugs
          .map((e) => Container(
              width: 24,
              height: 24,
              child: PerkIconWidget(
                plugItemHash: e.plugItemHash ?? 0,
                itemHash: item.item.itemHash ?? 0,
              )))
          .toList(),
    );
  }
}

class DevToolsPlugSourcesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<DevToolsPlugSourcesBloc>();
    return Scaffold(
      appBar: AppBar(
        title: Text("Dev Tools Plug Sources check"),
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
                    context.read<DevToolsPlugSourcesBloc>().onlyWithIssues = p0;
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
              return DevToolsPlugSourcesViewItem(item);
            },
          ),
          Positioned(bottom: 8, left: 8, right: 8, child: NotificationsWidget()),
        ],
      ),
    );
  }
}
