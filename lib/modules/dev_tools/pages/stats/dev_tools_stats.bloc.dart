import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/shared/utils/helpers/stat_helpers.dart';
import 'package:provider/provider.dart';

class StatsItem {
  final DestinyItemInfo item;
  final List<StatValues> stats;
  final Map<int, int?> precalculated;

  bool get hasIssues {
    for (final stat in stats) {
      final hash = stat.statHash;
      final equipped = stat.equipped + stat.equippedMasterwork;
      final precalc = precalculated[hash] ?? 0;
      if (precalc != equipped) {
        return true;
      }
    }
    return false;
  }

  StatsItem(this.item, this.stats, this.precalculated);
}

class DevToolsStatsBloc extends ChangeNotifier {
  @protected
  final BuildContext context;

  final ProfileBloc _profile;
  final ManifestService _manifest;

  List<StatsItem>? allItems;
  List<StatsItem>? _itemsWithIssues;

  List<StatsItem>? get items => _onlyWithIssues ? _itemsWithIssues : allItems;

  bool _onlyWithIssues = true;
  bool get onlyWithIssues => _onlyWithIssues;
  set onlyWithIssues(bool value) {
    _onlyWithIssues = value;
    notifyListeners();
  }

  DevToolsStatsBloc(this.context)
      : _profile = context.read<ProfileBloc>(),
        _manifest = context.read<ManifestService>(),
        super() {
    init();
  }

  init() {
    _profile.addListener(_update);
    _update();
  }

  dispose() {
    _profile.removeListener(_update);
    super.dispose();
  }

  _update() async {
    final items = _profile.allInstancedItems;
    final allItems = <StatsItem>[];
    for (final item in items) {
      final itemHash = item.itemHash;
      final sockets = item.sockets;
      final precalculated = item.stats?.map((key, value) => MapEntry(value.statHash ?? 0, value.value));
      if (itemHash == null || sockets == null || precalculated == null) continue;
      final equippedPlugHashes = <int, int?>{for (var v in sockets) sockets.indexOf(v): v.plugHash};
      final itemDefinition = await _manifest.getDefinition<DestinyInventoryItemDefinition>(item.itemHash);
      final statGroupDefinition =
          await _manifest.getDefinition<DestinyStatGroupDefinition>(itemDefinition?.stats?.statGroupHash);
      final plugDefinitions =
          await _manifest.getDefinitions<DestinyInventoryItemDefinition>(equippedPlugHashes.values.toList());
      final stats = await calculateStats(
        equippedPlugHashes,
        equippedPlugHashes,
        itemDefinition,
        statGroupDefinition,
        plugDefinitions,
      );
      if (stats == null) continue;
      allItems.add(StatsItem(item, stats, precalculated));
    }
    this.allItems = allItems;
    this._itemsWithIssues = allItems.where((element) => element.hasIssues).toList();
    notifyListeners();
  }
}
