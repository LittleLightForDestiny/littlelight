import 'package:flutter/material.dart';
import 'package:little_light/core/providers/language/language.consumer.dart';
import 'package:provider/provider.dart';

class CoreProvidersContainer extends StatelessWidget {
  final Widget child;
  CoreProvidersContainer(this.child);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => getInjectedLanguageService()),
      ],
      builder: (context, _) => child,
    );
  }
}
