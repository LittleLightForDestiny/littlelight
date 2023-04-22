import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/item_notes/item_notes.bloc.dart';
import 'package:provider/provider.dart';

class EditItemNotesBloc extends ChangeNotifier {
  final ItemNotesBloc _itemNotesBloc;
  final int itemHash;
  final String? itemInstanceId;

  String? _customName;

  final BuildContext _context;
  String? get customName => _customName;
  set customName(String? value) => _customName = value;
  String? _itemNotes;
  String? get itemNotes => _itemNotes;
  set itemNotes(String? value) => _itemNotes = value;
  EditItemNotesBloc(this._context, this.itemHash, this.itemInstanceId)
      : this._itemNotesBloc = _context.read<ItemNotesBloc>(),
        super() {
    _init();
  }
  void _init() {
    _customName = _itemNotesBloc.customNameFor(itemHash, itemInstanceId);
    _itemNotes = _itemNotesBloc.notesFor(itemHash, itemInstanceId);
  }

  void cancel() {
    Navigator.of(_context).pop();
  }

  void save() {
    _itemNotesBloc.updateNotes(itemHash, itemInstanceId, customName: _customName ?? "", notes: _itemNotes ?? "");
    Navigator.of(_context).pop();
  }
}
