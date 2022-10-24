import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'loadouts_home.bloc.dart';
import 'loadouts_home.view.dart';

class LoadoutsHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LoadoutsHomeBloc(
            context,
          ),
        ),
      ],
      child: LoadoutsHomeView(),
    );
  }
}
