import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'edit_loadout.bloc.dart';
import 'edit_loadout.page_route.dart';
import 'edit_loadout.view.dart';

class EditLoadoutPage extends StatelessWidget {
  final EditLoadoutPageRouteArguments args;

  EditLoadoutPage(this.args);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: this.args),
        ChangeNotifierProvider(create: (context) => EditLoadoutBloc(context)),
      ],
      child: EditLoadoutView(),
    );
  }
}
