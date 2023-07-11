import 'package:flutter/material.dart';
import 'dev_tools_plug_sources.bloc.dart';
import 'dev_tools_plug_sources.view.dart';
import 'package:provider/provider.dart';

class DevToolsPlugSourcesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DevToolsPlugSourcesBloc(context)),
      ],
      builder: (context, _) => DevToolsPlugSourcesView(),
    );
  }
}
