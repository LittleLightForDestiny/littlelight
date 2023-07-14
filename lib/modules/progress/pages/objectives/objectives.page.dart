import 'package:flutter/material.dart';
import 'package:little_light/modules/progress/pages/objectives/objectives.bloc.dart';
import 'package:little_light/modules/progress/pages/objectives/objectives.view.dart';
import 'package:provider/provider.dart';

class ObjectivesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => ObjectivesBloc(context))],
      builder: (context, _) => ObjectivesView(
        context.read<ObjectivesBloc>(),
        context.watch<ObjectivesBloc>(),
      ),
    );
  }
}
