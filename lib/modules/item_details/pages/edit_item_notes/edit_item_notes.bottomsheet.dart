import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/modules/item_details/pages/edit_item_notes/edit_item_notes.bloc.dart';
import 'package:little_light/modules/item_details/pages/edit_item_notes/edit_item_notes.view.dart';
import 'package:little_light/shared/widgets/modals/base_bottom_sheet.base.dart';
import 'package:provider/provider.dart';

class EditItemNotesBottomSheet extends BaseBottomSheet<int> {
  final int itemHash;
  final String? instanceId;
  EditItemNotesBottomSheet(this.itemHash, this.instanceId);
  @override
  Widget? buildHeader(BuildContext context) {
    return Text("Edit item notes".translate(context).toUpperCase());
  }

  @override
  Widget buildContent(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => EditItemNotesBloc(context, itemHash, instanceId))],
      builder: (context, child) => EditItemNotesView(
        bloc: context.read<EditItemNotesBloc>(),
        state: context.watch<EditItemNotesBloc>(),
      ),
    );
  }
}
