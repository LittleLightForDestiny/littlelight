import 'package:flutter/material.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_info.dart';
import 'package:little_light/modules/loadouts/pages/loadout_item_options/loadout_item_options.bottomsheet.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:provider/provider.dart';

class LoadoutItemOptionsBloc extends ChangeNotifier {
  final BuildContext _context;
  final SocketControllerBloc _socketControllerBloc;

  final LoadoutItemInfo item;

  LoadoutItemOptionsBloc(this._context, this.item)
      : _socketControllerBloc = _context.read<SocketControllerBloc>(),
        super() {
    _init();
  }
  void _init() {
    _socketControllerBloc.init(item);
  }

  void cancel() {
    Navigator.of(_context).pop();
  }

  void selectOption(LoadoutItemOption option) {
    Navigator.of(_context).pop(option);
  }
}
