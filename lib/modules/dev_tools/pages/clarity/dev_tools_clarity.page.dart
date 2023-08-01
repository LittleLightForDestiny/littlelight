import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/clarity/clarity_data.bloc.dart';
import 'package:little_light/modules/dev_tools/pages/clarity/dev_tools_clarity.bloc.dart';
import 'package:little_light/modules/dev_tools/pages/clarity/dev_tools_clarity.view.dart';
import 'package:provider/provider.dart';

class DevToolsClarityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ClarityDataBloc()),
        ChangeNotifierProvider(create: (context) => DevToolsClarityBloc(context)),
      ],
      builder: (context, _) => DevToolsClarityView(),
    );
  }
}
