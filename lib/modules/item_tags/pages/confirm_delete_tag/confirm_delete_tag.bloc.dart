import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/item_notes/item_notes.bloc.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:provider/provider.dart';

class DeleteTagBloc extends ChangeNotifier {
  final ItemNotesBloc _itemNotesBloc;
  final BuildContext _context;

  ItemNotesTag _tag;

  DeleteTagBloc(this._context, ItemNotesTag this._tag)
      : this._itemNotesBloc = _context.read<ItemNotesBloc>(),
        super() {}

  ItemNotesTag get tag => _tag;

  @override
  void dispose() {
    super.dispose();
    _itemNotesBloc.removeListener(notifyListeners);
  }

  void cancel() {
    Navigator.of(_context).pop();
  }

  void delete() {
    _itemNotesBloc.deleteTag(_tag);
    Navigator.of(_context).pop();
  }
}
