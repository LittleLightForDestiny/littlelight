import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/modules/item_details/blocs/socket_controller.bloc.dart';
import 'package:little_light/shared/widgets/containers/persistent_collapsible_container.dart';
import 'package:provider/provider.dart';

import 'details_item_stat.widget.dart';

const _sectionId = "item_stats";

class DetailsItemStatsWidget extends StatelessWidget {
  const DetailsItemStatsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SocketControllerBloc>();
    final stats = state.stats;
    if (stats == null || stats.isEmpty) return Container();
    return Container(
      padding: EdgeInsets.all(4),
      child: PersistentCollapsibleContainer(
        title: Text("Stats".translate(context).toUpperCase()),
        content: buildContent(context),
        persistenceID: 'item_stats',
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    return Column(
      children: buildStats(context),
    );
  }

  List<Widget> buildStats(BuildContext context) {
    final state = context.watch<SocketControllerBloc>();
    final stats = state.stats;
    if (stats == null) return [];
    return stats
        .map((value) => DetailsItemStatWidget(
              modValues: value,
            ))
        .toList();
  }
}
