import 'package:flutter/material.dart';
import 'package:little_light/modules/settings/pages/change_language/change_language.bloc.dart';
import 'package:little_light/modules/settings/pages/change_language/change_language.view.dart';
import 'package:provider/provider.dart';

class ChangeLanguagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (c) => ChangeLanguageBloc(c),
        )
      ],
      builder: (c, _) => ChangeLanguageView(
        bloc: c.read<ChangeLanguageBloc>(),
        state: c.watch<ChangeLanguageBloc>(),
      ),
    );
  }
}
