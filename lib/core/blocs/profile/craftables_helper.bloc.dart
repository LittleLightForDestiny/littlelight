import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/littlelight_data/littlelight_data.bloc.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/shared/utils/helpers/plug_helpers.dart';
import 'package:provider/provider.dart';

class CraftablesHelperBloc extends ChangeNotifier {
  ProfileBloc _profileBloc;
  ManifestService _manifest;
  LittleLightDataBloc _littleLightDataBloc;

  Map<int, int?> _itemToRecordHashMap = {};

  Map<int, int?> _itemToCraftedPlugHashMap = {};

  CraftablesHelperBloc(BuildContext context)
      : _profileBloc = context.read<ProfileBloc>(),
        _manifest = context.read<ManifestService>(),
        _littleLightDataBloc = context.read<LittleLightDataBloc>(),
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

  List<DestinyObjectiveProgress>? getItemCraftedObjectives(DestinyItemInfo item) {
    final hasKey = _itemToCraftedPlugHashMap.containsKey(item.itemHash);
    if (!hasKey) {
      _loadCraftedObjectivesPlugHash(item);
      return null;
    }
    final plugHash = _itemToCraftedPlugHashMap[item.itemHash];
    final objectives = item.plugObjectives?["$plugHash"];
    return objectives;
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

  void _loadCraftedObjectivesPlugHash(DestinyItemInfo item) async {
    final itemHash = item.itemHash;
    if (_itemToCraftedPlugHashMap.containsKey(itemHash)) return;
    if (itemHash == null) return;
    final gameData = _littleLightDataBloc.gameData;
    if (gameData == null) return;
    final isCrafted = item.state?.contains(ItemState.Crafted) ?? false;
    if (!isCrafted) return;
    final plugHashes = item.sockets?.map((s) => s.plugHash);
    if (plugHashes == null) return;
    _itemToCraftedPlugHashMap[itemHash] = null;
    final defs = await _manifest.getDefinitions<DestinyInventoryItemDefinition>(plugHashes);
    final craftedDef = defs.values.firstWhereOrNull((def) => isCraftedProgressPlug(gameData, def));
    _itemToCraftedPlugHashMap[itemHash] = craftedDef?.hash;
    notifyListeners();
  }
}
