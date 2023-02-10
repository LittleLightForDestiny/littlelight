import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';

const _shaderRootHash = 2381001021;

class SelectLoadoutBackgroundBloc extends ChangeNotifier with ManifestConsumer {
  final BuildContext context;
  List<DestinyPresentationNodeDefinition>? _nodesDefinitions;
  List<DestinyPresentationNodeDefinition>? get nodesDefinitions => _nodesDefinitions;
  final Set<int> _openedCategories = <int>{};
  final Map<int, List<DestinyInventoryItemDefinition>> _categoryItems = <int, List<DestinyInventoryItemDefinition>>{};

  SelectLoadoutBackgroundBloc(this.context) {
    _asyncInit();
  }

  _asyncInit() async {
    await Future.delayed(Duration.zero);
    final route = ModalRoute.of(context);
    await Future.delayed(route?.transitionDuration ?? Duration.zero);
    _loadNodes();
  }

  Future<void> _loadNodes() async {
    await Future.delayed(Duration.zero);
    final route = ModalRoute.of(context);
    await Future.delayed(route?.transitionDuration ?? Duration.zero);
    final categoryDefinition = await manifest.getDefinition<DestinyPresentationNodeDefinition>(_shaderRootHash);
    final nodeHashes = categoryDefinition?.children?.presentationNodes?.map((e) => e.presentationNodeHash);
    if (nodeHashes == null) return;
    final nodesDefinitions = await manifest.getDefinitions<DestinyPresentationNodeDefinition>(nodeHashes);

    _nodesDefinitions = nodesDefinitions.values.toList();
    notifyListeners();
  }

  void toggleCategory(int hash) async {
    if (_openedCategories.contains(hash)) {
      _openedCategories.remove(hash);
    } else {
      _openedCategories.add(hash);
    }
    notifyListeners();

    if (!_categoryItems.containsKey(hash) && _openedCategories.contains(hash)) {
      final category = _nodesDefinitions?.firstWhereOrNull((def) => def.hash == hash);
      final collectibleHashes = category?.children?.collectibles?.map((c) => c.collectibleHash);
      if (collectibleHashes == null) return;
      final collectibles = await manifest.getDefinitions<DestinyCollectibleDefinition>(collectibleHashes);
      final itemHashes = collectibles.values.map((e) => e.itemHash).whereType<int>();
      final items = await manifest.getDefinitions<DestinyInventoryItemDefinition>(itemHashes);
      final alreadyAddedImages = <String>[];
      final categoryItems = collectibleHashes
          .map((h) => collectibles[h]?.itemHash)
          .whereType<int>()
          .map((itemHash) => items[itemHash])
          .whereType<DestinyInventoryItemDefinition>()
          .where((item) {
        final secondarySpecial = item.secondarySpecial;
        if (secondarySpecial == null) return false;
        final alreadyAdded = alreadyAddedImages.contains(secondarySpecial);
        alreadyAddedImages.add(secondarySpecial);
        return !alreadyAdded;
      }).toList();

      _categoryItems[hash] = categoryItems;
      notifyListeners();
    }
  }

  bool isCategoryOpen(int hash) {
    return _openedCategories.contains(hash);
  }

  List<DestinyInventoryItemDefinition>? getCategoryItems(int hash) {
    return _categoryItems[hash];
  }
}
