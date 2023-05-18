import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/shared/widgets/modals/base_bottom_sheet.base.dart';
import 'package:provider/provider.dart';

import 'confirm_delete_loadout.bloc.dart';
import 'confirm_delete_loadout.view.dart';

class ConfirmDeleteLoadoutBottomSheet extends BaseBottomSheet<int> {
  final String id;
  ConfirmDeleteLoadoutBottomSheet(this.id);
  @override
  Widget? buildHeader(BuildContext context) {
    return Text("Delete loadout".translate(context).toUpperCase());
  }

  @override
  Widget buildContent(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => DeleteLoadoutBloc(context, id))],
      builder: (context, child) => DeleteLoadoutView(
        bloc: context.read<DeleteLoadoutBloc>(),
        state: context.watch<DeleteLoadoutBloc>(),
      ),
    );
  }
}
