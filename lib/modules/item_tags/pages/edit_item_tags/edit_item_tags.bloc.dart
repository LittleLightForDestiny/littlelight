import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/item_notes/item_notes.bloc.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/modules/item_tags/blocs/select_tags.bloc.dart';
import 'package:little_light/modules/item_tags/pages/edit_item_tags/edit_item_tags.bottomsheet.dart';
import 'package:provider/provider.dart';

class EditItemTagsBloc extends SelectTagsBloc {
  final ItemNotesBloc _itemNotesBloc;
  final int itemHash;
  final String? itemInstanceId;
  final BuildContext _context;

  EditItemTagsBloc(this._context, this.itemHash, this.itemInstanceId)
      : this._itemNotesBloc = _context.read<ItemNotesBloc>(),
        super(_context) {
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

  @override
  void remove(ItemNotesTag tag) {
    final id = tag.tagId;
    if (id == null) return;
    _itemNotesBloc.removeTag(itemHash, itemInstanceId, id);
  }

  @override
  void add(ItemNotesTag tag) {
    final id = tag.tagId;
    if (id == null) return;
    _itemNotesBloc.addTag(itemHash, itemInstanceId, id);
    Navigator.of(_context).pop();
  }

  @override
  List<ItemNotesTag> get tagsToRemove => _itemNotesBloc.tagsFor(itemHash, itemInstanceId) ?? [];

  @override
  List<ItemNotesTag> get tagsToAdd {
    final currentTags = _itemNotesBloc.tagIdsFor(itemHash, itemInstanceId) ?? {};
    final available = _itemNotesBloc.availableTags.where((element) => !currentTags.contains(element.tagId));
    return available.toList();
  }

  @override
  void reopen(BuildContext navigatorContext) {
    EditItemTagsBottomSheet(itemHash, itemInstanceId).show(navigatorContext);
  }
}
