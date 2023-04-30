import 'package:flutter/material.dart';
import 'package:little_light/modules/triumphs/blocs/base_triumphs.bloc.dart';
import 'package:provider/provider.dart';

import 'triumphs_home.bloc.dart';
import 'triumphs_home.view.dart';

class TriumphsHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TriumphsBloc>(create: (context) => TriumphsHomeBloc(context)),
      ],
      builder: (context, _) => TriumphsHomeView(
        context.read<TriumphsBloc>(),
        context.watch<TriumphsBloc>(),
      ),
    );
  }
}
