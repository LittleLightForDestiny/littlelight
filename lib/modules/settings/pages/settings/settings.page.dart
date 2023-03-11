import 'package:flutter/material.dart';
import 'package:little_light/modules/settings/pages/settings/settings.bloc.dart';
import 'package:provider/provider.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'settings.view.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsBloc(context)),
      ],
      builder: (context, _) => SettingsView(
        context.read<SettingsBloc>(),
        context.watch<SettingsBloc>(),
      ),
    );
  }
}
