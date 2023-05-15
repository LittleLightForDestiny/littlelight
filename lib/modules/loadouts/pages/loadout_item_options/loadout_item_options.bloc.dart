import 'package:flutter/material.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_index.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_info.dart';
import 'package:little_light/modules/loadouts/pages/loadout_item_options/loadout_item_options.bottomsheet.dart';

class LoadoutItemOptionsBloc extends ChangeNotifier {
  final BuildContext _context;

  final LoadoutItemInfo item;

  LoadoutItemOptionsBloc(this._context, this.item) : super() {
    _init();
  }
  void _init() {}

  void cancel() {
    Navigator.of(_context).pop();
  }

  void selectOption(LoadoutItemOption option) {
    Navigator.of(_context).pop(option);
  }
}
