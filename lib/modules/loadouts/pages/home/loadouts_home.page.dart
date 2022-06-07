import 'package:flutter/material.dart';
import 'package:little_light/modules/loadouts/pages/home/loadouts_home.provider.dart';
import 'package:little_light/modules/loadouts/pages/home/loadouts_home.view.dart';
import 'package:provider/provider.dart';

class LoadoutsHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LoadoutsHomeProvider(context)),
      ],
      child: LoadoutsHomeView(),
    );
  }
}
