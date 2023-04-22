import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/shared/widgets/modals/base_bottom_sheet.base.dart';
import 'package:provider/provider.dart';

import 'edit_tag.bloc.dart';
import 'edit_tag.view.dart';

class EditTagBottomSheet extends BaseBottomSheet<int> {
  final ItemNotesTag? tag;
  EditTagBottomSheet(this.tag);
  @override
  Widget? buildHeader(BuildContext context) {
    final isNew = tag == null;
    return Text(
      isNew
          ? "Create tag".translate(context).toUpperCase() //
          : "Edit tag".translate(context).toUpperCase(),
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => EditTagBloc(context, tag))],
      builder: (context, child) => EditTagView(
        bloc: context.read<EditTagBloc>(),
        state: context.watch<EditTagBloc>(),
      ),
    );
  }
}
