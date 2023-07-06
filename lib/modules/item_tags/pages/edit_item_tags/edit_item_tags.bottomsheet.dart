import 'package:flutter/material.dart';
import 'package:little_light/shared/widgets/modals/base_bottom_sheet.base.dart';
import 'package:provider/provider.dart';
import 'edit_item_tags.bloc.dart';
import 'edit_item_tags.view.dart';

class EditItemTagsBottomSheet extends BaseBottomSheet<int> {
  final int itemHash;
  final String? instanceId;
  EditItemTagsBottomSheet(this.itemHash, this.instanceId);
  @override
  Widget? buildHeader(BuildContext context) => null;

  @override
  Widget buildContent(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => EditItemTagsBloc(context, itemHash, instanceId))],
      builder: (context, child) => EditItemTagsView(
        bloc: context.read<EditItemTagsBloc>(),
        state: context.watch<EditItemTagsBloc>(),
      ),
    );
  }
}
