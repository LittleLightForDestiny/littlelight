import 'package:flutter/material.dart';
import 'package:little_light/shared/widgets/modals/base_bottom_sheet.base.dart';
import 'package:provider/provider.dart';
import 'edit_priority_tags.bloc.dart';
import 'edit_priority_tags.view.dart';

class EditPriorityTagsBottomSheet extends BaseBottomSheet<int> {
  EditPriorityTagsBottomSheet();
  @override
  Widget? buildHeader(BuildContext context) => null;

  @override
  Widget buildContent(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => EditPriorityTagsBloc(context))],
      builder: (context, child) => EditPriorityTagsView(
        bloc: context.read<EditPriorityTagsBloc>(),
        state: context.watch<EditPriorityTagsBloc>(),
      ),
    );
  }

  @override
  Future<int?> show(BuildContext context) async {
    final result = await showModalBottomSheet(context: context, builder: (context) => this, isScrollControlled: true);
    if (result is int) return result;
    return null;
  }
}
