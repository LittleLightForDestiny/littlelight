import 'package:flutter/material.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:provider/provider.dart';
import 'details_item_cover_stat.widget.dart';

class DetailsItemCoverStatsWidget extends StatelessWidget {
  final double pixelSize;
  const DetailsItemCoverStatsWidget({
    Key? key,
    this.pixelSize = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SocketControllerBloc>();
    final stats = state.stats;
    if (stats == null || stats.isEmpty) return Container();
    final total = buildTotalStats(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ...buildStats(context),
        if (total != null) total,
      ],
    );
  }

  List<Widget> buildStats(BuildContext context) {
    final state = context.watch<SocketControllerBloc>();
    final stats = state.stats;
    if (stats == null) return [];
    return stats
        .map((value) => DetailsItemCoverStatWidget(
              modValues: value,
              pixelSize: pixelSize,
            ))
        .toList();
  }

  Widget? buildTotalStats(BuildContext context) {
    final state = context.watch<SocketControllerBloc>();
    final stat = state.totalStats;
    if (stat == null) return null;
    return DetailsCoverTotalItemStatWidget(
      modValues: stat,
      pixelSize: pixelSize,
    );
  }
}
