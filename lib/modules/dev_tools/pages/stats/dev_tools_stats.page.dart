import 'package:flutter/material.dart';
import 'package:little_light/modules/dev_tools/pages/stats/dev_tools_stats.bloc.dart';
import 'package:little_light/modules/dev_tools/pages/stats/dev_tools_stats.view.dart';
import 'package:provider/provider.dart';

class DevToolsStatsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DevToolsStatsBloc(context)),
      ],
      builder: (context, _) => DevToolsStatsView(),
    );
  }
}
