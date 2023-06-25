import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/item_notes/item_notes.bloc.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/modules/item_tags/blocs/select_tags.bloc.dart';
import 'package:little_light/modules/item_tags/pages/edit_priority_tags/edit_priority_tags.bottomsheet.dart';
import 'package:provider/provider.dart';

class EditPriorityTagsBloc extends SelectTagsBloc {
  final ItemNotesBloc _itemNotes;
  final UserSettingsBloc _userSettings;
  final BuildContext _context;

  EditPriorityTagsBloc(this._context)
      : this._itemNotes = _context.read<ItemNotesBloc>(),
        this._userSettings = _context.read<UserSettingsBloc>(),
        super(_context) {
    _init();
  }
  void _init() {
    _userSettings.addListener(notifyListeners);
  }

  @override
  void dispose() {
    super.dispose();
    _userSettings.removeListener(notifyListeners);
  }

  @override
  void remove(ItemNotesTag tag) {
    final id = tag.tagId;
    if (id == null) return;
    _userSettings.removePriorityTag(tag);
  }

  @override
  void add(ItemNotesTag tag) {
    final id = tag.tagId;
    if (id == null) return;
    _userSettings.addPriorityTag(tag);
    Navigator.of(_context).pop();
  }

  @override
  List<ItemNotesTag> get tagsToRemove => _itemNotes.tagsByIds(
        _userSettings.priorityTags?.whereType<String>().toSet() ?? <String>{},
      );

  @override
  List<ItemNotesTag> get tagsToAdd {
    final currentTags = _userSettings.priorityTags?.whereType<String>();
    final allAvailable = _itemNotes.availableTags;
    if (currentTags == null || currentTags.isEmpty) return allAvailable;
    final available = _itemNotes.availableTags.where((element) => !currentTags.contains(element.tagId));
    return available.toList();
  }

  @override
  void reopen(BuildContext navigatorContext) {
    EditPriorityTagsBottomSheet().show(navigatorContext);
  }
}
