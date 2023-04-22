import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/shared/widgets/modals/base_bottom_sheet.base.dart';
import 'package:provider/provider.dart';

import 'confirm_delete_tag.bloc.dart';
import 'confirm_delete_tag.view.dart';

class ConfirmDeleteTagBottomSheet extends BaseBottomSheet<int> {
  final ItemNotesTag tag;
  ConfirmDeleteTagBottomSheet(this.tag);
  @override
  Widget? buildHeader(BuildContext context) {
    return Text("Delete tag".translate(context).toUpperCase());
  }

  @override
  Widget buildContent(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => DeleteTagBloc(context, tag))],
      builder: (context, child) => DeleteTagView(
        bloc: context.read<DeleteTagBloc>(),
        state: context.watch<DeleteTagBloc>(),
      ),
    );
  }
}
