import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/models/destiny_loadout.dart';
import 'package:little_light/shared/widgets/modals/base_bottom_sheet.base.dart';
import 'package:provider/provider.dart';
import 'confirm_delete_destiny_loadout.bloc.dart';
import 'confirm_delete_destiny_loadout.view.dart';

class ConfirmDeleteDestinyLoadoutBottomSheet extends BaseBottomSheet<bool> {
  final DestinyLoadoutInfo loadout;
  ConfirmDeleteDestinyLoadoutBottomSheet(this.loadout);
  @override
  Widget? buildHeader(BuildContext context) {
    return Text("Delete loadout".translate(context).toUpperCase());
  }

  @override
  Widget buildContent(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => DeleteDestinyLoadoutBloc(context, loadout))],
      builder: (context, child) => DeleteDestinyLoadoutView(
        bloc: context.read<DeleteDestinyLoadoutBloc>(),
        state: context.watch<DeleteDestinyLoadoutBloc>(),
      ),
    );
  }
}
