import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:provider/provider.dart';

class VendorsHomeBloc extends ChangeNotifier {
  ProfileBloc _profileBloc;

  final PageStorageBucket _pageStorageBucket = PageStorageBucket();
  PageStorageBucket get pageStorageBucket => _pageStorageBucket;

  Map<String, bool> _hasStartedLoading = {};
  Map<String, List<DestinyVendorComponent>> _characterVendorData = {};

  VendorsHomeBloc(BuildContext context) : _profileBloc = context.read<ProfileBloc>();

  List<DestinyCharacterInfo>? get characters {
    return _profileBloc.characters;
  }

  List<DestinyVendorComponent>? getVendorsFor(String characterId) {
    final startedLoading = _hasStartedLoading[characterId] ?? false;
    if (!startedLoading) _loadDataFor(characterId);
  }

  void _loadDataFor(String characterId) async {
    _hasStartedLoading[characterId] = true;
  }
}
