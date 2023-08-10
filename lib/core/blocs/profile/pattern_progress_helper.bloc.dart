import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:provider/provider.dart';

class PatternProgressHelperBloc extends ChangeNotifier {
  ProfileBloc _profileBloc;
  ManifestService _manifest;

  Map<int, int?> _itemToRecordHashMap = {};

  PatternProgressHelperBloc(BuildContext context)
      : _profileBloc = context.read<ProfileBloc>(),
        _manifest = context.read<ManifestService>(),
        super();

  DestinyRecordComponent? getPatternProgressRecord(int itemHash) {
    final hasKey = _itemToRecordHashMap.containsKey(itemHash);
    if (!hasKey) {
      _loadRecordHash(itemHash);
      return null;
    }
    final recordHash = _itemToRecordHashMap[itemHash];
    if (recordHash == null) return null;
    return _profileBloc.getProfileRecord(recordHash);
  }

  void _loadRecordHash(int itemHash) async {
    if (_itemToRecordHashMap.containsKey(itemHash)) return;
    _itemToRecordHashMap[itemHash] = null;
    final itemDef = await _manifest.getDefinition<DestinyInventoryItemDefinition>(itemHash);
    final recipeHash = itemDef?.inventory?.recipeItemHash;
    if (recipeHash == null) return;
    final name = itemDef?.displayProperties?.name;
    if (name == null) return;
    final recordDefs = await _manifest.searchDefinitions<DestinyRecordDefinition>([name]);
    final recordDef = recordDefs.values.firstWhereOrNull((element) =>
        element.displayProperties?.name == name &&
        element.completionInfo?.toastStyle == DestinyRecordToastStyle.CraftingRecipeUnlocked);
    if (recordDef == null) return;
    _itemToRecordHashMap[itemHash] = recordDef.hash;
    notifyListeners();
  }
}
