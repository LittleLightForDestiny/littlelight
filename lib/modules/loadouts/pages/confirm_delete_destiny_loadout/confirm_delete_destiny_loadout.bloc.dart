import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/models/destiny_loadout.dart';
import 'package:provider/provider.dart';

class DeleteDestinyLoadoutBloc extends ChangeNotifier {
  final ProfileBloc _profileBloc;
  final BuildContext _context;
  bool _busy = false;
  bool get busy => _busy;

  DestinyLoadoutInfo loadout;

  DeleteDestinyLoadoutBloc(this._context, this.loadout)
      : this._profileBloc = _context.read<ProfileBloc>(),
        super();

  void cancel() {
    Navigator.of(_context).pop(false);
  }

  void delete() async {
    _busy = true;
    notifyListeners();
    await _profileBloc.deleteLoadout(loadout);
    Navigator.of(_context).pop(true);
  }
}
