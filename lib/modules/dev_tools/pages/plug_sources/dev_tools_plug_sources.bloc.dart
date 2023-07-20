import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/core/utils/logger/logger.wrapper.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:provider/provider.dart';

class DevToolsPlugSourcesItem {
  final DestinyItemInfo item;
  final DestinyInventoryItemDefinition? definition;

  bool get hasIssues {
    return socketsWithWrongPlugSources.length > 0;
  }

  List<int> get socketsWithWrongPlugSources {
    final socketsWithIssues = <int>[];
    final sockets = definition?.sockets?.socketEntries;
    if (sockets == null) return [];
    for (int index = 0; index < sockets.length; index++) {
      final reusable = item.reusablePlugs?["$index"];
      final socket = sockets[index];

      if (reusable == null) continue;
      if (reusable.isEmpty) continue;
      if (socket.plugSources?.value == 0) {
        socketsWithIssues.add(index);
      }
    }
    return socketsWithIssues;
  }

  DevToolsPlugSourcesItem(this.item, this.definition);
}

class DevToolsPlugSourcesBloc extends ChangeNotifier {
  @protected
  final BuildContext context;

  final ProfileBloc _profile;
  final ManifestService _manifest;

  List<DevToolsPlugSourcesItem>? allItems;
  List<DevToolsPlugSourcesItem>? _itemsWithIssues;

  List<DevToolsPlugSourcesItem>? get items => _onlyWithIssues ? _itemsWithIssues : allItems;

  bool _onlyWithIssues = true;
  bool get onlyWithIssues => _onlyWithIssues;
  set onlyWithIssues(bool value) {
    _onlyWithIssues = value;
    notifyListeners();
  }

  DevToolsPlugSourcesBloc(this.context)
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
    final allItems = <DevToolsPlugSourcesItem>[];
    for (final item in items) {
      final itemDefinition = await _manifest.getDefinition<DestinyInventoryItemDefinition>(item.itemHash);
      allItems.add(DevToolsPlugSourcesItem(item, itemDefinition));
    }
    this.allItems = allItems;
    this._itemsWithIssues = allItems.where((element) => element.hasIssues).toList();
    logger.info("${this._itemsWithIssues?.length} of ${this.allItems?.length} items with issues");
    notifyListeners();
  }
}
