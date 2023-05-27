import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/core/blocs/loadouts/loadout_item_index.dart';
import 'package:little_light/core/blocs/loadouts/loadouts.bloc.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/shared/utils/helpers/loadout_helpers.dart';
import 'package:provider/provider.dart';

class DeleteLoadoutBloc extends ChangeNotifier {
  final LoadoutsBloc _loadoutsBloc;
  final ProfileBloc _profileBloc;
  final ManifestService _manifestBloc;
  final BuildContext _context;

  String loadoutId;
  LoadoutItemIndex? _itemIndex;
  Loadout? _loadout;

  DeleteLoadoutBloc(this._context, this.loadoutId)
      : this._loadoutsBloc = _context.read<LoadoutsBloc>(),
        this._profileBloc = _context.read<ProfileBloc>(),
        this._manifestBloc = _context.read<ManifestService>(),
        super() {
    _init();
  }

  _init() async {
    final loadout = _loadoutsBloc.getLoadout(loadoutId);
    final itemIndex = await loadout?.generateIndex(profile: _profileBloc, manifest: _manifestBloc);
    this._loadout = loadout;
    this._itemIndex = itemIndex;
    notifyListeners();
  }

  LoadoutItemIndex? get loadout => _itemIndex;

  @override
  void dispose() {
    super.dispose();
    _loadoutsBloc.removeListener(notifyListeners);
  }

  void cancel() {
    Navigator.of(_context).pop();
  }

  void delete() {
    final loadout = this._loadout;
    if (loadout != null) _loadoutsBloc.deleteLoadout(loadout);
    Navigator.of(_context).pop();
  }
}
