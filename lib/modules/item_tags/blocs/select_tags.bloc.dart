import 'package:flutter/material.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/modules/item_tags/pages/confirm_delete_tag/confirm_delete_tag.bottomsheet.dart';
import 'package:little_light/modules/item_tags/pages/edit_tag/edit_tag.bottomsheet.dart';

abstract class SelectTagsBloc extends ChangeNotifier {
  final BuildContext _context;

  SelectTagsBloc(this._context) : super();

  void cancel() {
    Navigator.of(_context).pop();
  }

  void remove(ItemNotesTag tag);

  void add(ItemNotesTag tag);

  List<ItemNotesTag> get tagsToRemove;
  List<ItemNotesTag> get tagsToAdd;

  void edit(ItemNotesTag tag) async {
    final navigatorContext = Navigator.of(_context).context;
    Navigator.of(navigatorContext).pop(navigatorContext);
    await EditTagBottomSheet(tag).show(navigatorContext);
    reopen(navigatorContext);
  }

  void delete(ItemNotesTag tag) async {
    final navigatorContext = Navigator.of(_context).context;
    Navigator.of(navigatorContext).pop(navigatorContext);
    await ConfirmDeleteTagBottomSheet(tag).show(navigatorContext);
    reopen(navigatorContext);
  }

  void create() async {
    final navigatorContext = Navigator.of(_context).context;
    Navigator.of(navigatorContext).pop(navigatorContext);
    await EditTagBottomSheet(null).show(navigatorContext);
    reopen(navigatorContext);
  }

  void reopen(BuildContext navigatorContext);
}
