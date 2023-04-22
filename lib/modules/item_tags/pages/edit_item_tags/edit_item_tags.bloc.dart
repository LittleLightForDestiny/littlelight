import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/item_notes/item_notes.bloc.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/modules/item_tags/pages/confirm_delete_tag/confirm_delete_tag.bottomsheet.dart';
import 'package:little_light/modules/item_tags/pages/edit_item_tags/edit_item_tags.bottomsheet.dart';
import 'package:little_light/modules/item_tags/pages/edit_tag/edit_tag.bottomsheet.dart';
import 'package:provider/provider.dart';

class EditItemTagsBloc extends ChangeNotifier {
  final ItemNotesBloc _itemNotesBloc;
  final int itemHash;
  final String? itemInstanceId;
  final BuildContext _context;

  EditItemTagsBloc(this._context, this.itemHash, this.itemInstanceId)
      : this._itemNotesBloc = _context.read<ItemNotesBloc>(),
        super() {
    _init();
  }
  void _init() {
    _itemNotesBloc.addListener(notifyListeners);
  }

  @override
  void dispose() {
    super.dispose();
    _itemNotesBloc.removeListener(notifyListeners);
  }

  void cancel() {
    Navigator.of(_context).pop();
  }

  void remove(ItemNotesTag tag) {
    final id = tag.tagId;
    if (id == null) return;
    _itemNotesBloc.removeTag(itemHash, itemInstanceId, id);
  }

  void add(ItemNotesTag tag) {
    final id = tag.tagId;
    if (id == null) return;
    _itemNotesBloc.addTag(itemHash, itemInstanceId, id);
    Navigator.of(_context).pop();
  }

  List<ItemNotesTag> get tagsToRemove => _itemNotesBloc.tagsFor(itemHash, itemInstanceId) ?? [];
  List<ItemNotesTag> get tagsToAdd {
    final currentTags = _itemNotesBloc.tagIdsFor(itemHash, itemInstanceId) ?? {};
    final available = _itemNotesBloc.availableTags.where((element) => !currentTags.contains(element.tagId));
    return available.toList();
  }

  void edit(ItemNotesTag tag) async {
    final navigatorContext = Navigator.of(_context).context;
    Navigator.of(navigatorContext).pop(navigatorContext);
    await EditTagBottomSheet(tag).show(navigatorContext);
    EditItemTagsBottomSheet(itemHash, itemInstanceId).show(navigatorContext);
  }

  void delete(ItemNotesTag tag) async {
    final navigatorContext = Navigator.of(_context).context;
    Navigator.of(navigatorContext).pop(navigatorContext);
    await ConfirmDeleteTagBottomSheet(tag).show(navigatorContext);
    EditItemTagsBottomSheet(itemHash, itemInstanceId).show(navigatorContext);
  }

  void create() async {
    final navigatorContext = Navigator.of(_context).context;
    Navigator.of(navigatorContext).pop(navigatorContext);
    await EditTagBottomSheet(null).show(navigatorContext);
    EditItemTagsBottomSheet(itemHash, itemInstanceId).show(navigatorContext);
  }
}
