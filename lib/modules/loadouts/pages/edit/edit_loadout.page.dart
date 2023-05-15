import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'edit_loadout.bloc.dart';
import 'edit_loadout.page_route.dart';
import 'edit_loadout.view.dart';

class EditLoadoutPage extends StatelessWidget {
  final EditLoadoutPageRouteArguments args;

  const EditLoadoutPage(this.args);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => EditLoadoutBloc(context, args)),
      ],
      builder: (context, _) => EditLoadoutView(context.read<EditLoadoutBloc>(), context.watch<EditLoadoutBloc>()),
    );
  }
}
