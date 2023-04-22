import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/item_notes/item_notes.bloc.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/utils/color_utils.dart';
import 'package:provider/provider.dart';

const _basicRootColors = [
  Colors.grey,
  Colors.blueGrey,
  Colors.red,
  Colors.deepOrange,
  Colors.orange,
  Colors.amber,
  Colors.yellow,
  Colors.lime,
  Colors.lightGreen,
  Colors.green,
  Colors.teal,
  Colors.cyan,
  Colors.lightBlue,
  Colors.blue,
  Colors.indigo,
  Colors.deepPurple,
  Colors.purple,
  Colors.pink,
  Colors.brown,
];

final _basicColors = _basicRootColors.fold<List<Color>>(
  [],
  (list, c) => list + [c.shade900, c.shade700, c.shade500, c.shade400, c.shade300, c.shade100],
);

final _backgroundColors = [Colors.transparent, Colors.black, Colors.white] + _basicColors;

class EditTagBloc extends ChangeNotifier {
  final ItemNotesBloc _itemNotesBloc;
  final BuildContext _context;

  bool _isNew = false;
  bool get isNew => _isNew;
  late ItemNotesTag _tag;
  ItemNotesTag get tag => _tag;

  EditTagBloc(this._context, ItemNotesTag? tag)
      : this._itemNotesBloc = _context.read<ItemNotesBloc>(),
        super() {
    _init(tag);
  }

  List<Color> get backgroundColors => _backgroundColors;
  List<Color> get foregroundColors => _basicColors;

  Color? get backgroundColor => _tag.backgroundColor;

  ItemTagIcon get icon => _tag.icon;
  IconData? get iconData => icon.iconData;

  List<ItemTagIcon> get icons => ItemTagIcon.values;

  set backgroundColor(Color? value) {
    _tag.backgroundColorHex = hexFromColor(value ?? Colors.transparent);
    notifyListeners();
  }

  Color? get foregroundColor => _tag.foregroundColor;
  set foregroundColor(Color? value) {
    _tag.foregroundColorHex = hexFromColor(value ?? Colors.white);
    notifyListeners();
  }

  set icon(ItemTagIcon value) {
    _tag.icon = value;
    notifyListeners();
  }

  String get tagName => _tag.name;
  set tagName(String value) {
    _tag.name = value;
    notifyListeners();
  }

  void _init(ItemNotesTag? tag) {
    _isNew = tag == null;
    this._tag = tag?.clone() ?? ItemNotesTag.newCustom();
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

  void save() {
    _itemNotesBloc.saveTag(_tag);
    Navigator.of(_context).pop();
  }
}
