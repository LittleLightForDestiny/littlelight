import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/modules/loadouts/blocs/loadouts.bloc.dart';
import 'package:provider/provider.dart';

class CoreBlocsContainer extends StatelessWidget {
  final Widget child;
  CoreBlocsContainer(this.child);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => getInjectedLanguageService()),
        ChangeNotifierProvider(create: (context) => LoadoutsBloc()),
      ],
      builder: (context, _) => child,
    );
  }
}
