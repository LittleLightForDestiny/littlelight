import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/core/blocs/profile/profile_component_groups.dart';
import 'package:little_light/core/blocs/selection/selection.bloc.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/models/item_info/definition_item_info.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';
import 'package:little_light/modules/item_details/pages/definition_item_details/definition_item_details.page_route.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/shared/utils/helpers/presentation_node_helpers.dart';
import 'package:provider/provider.dart';

abstract class CollectionsBloc extends ChangeNotifier {
  final BuildContext context;
  @protected
  final ProfileBloc profileBloc;
  @protected
  final UserSettingsBloc userSettings;
  @protected
  final ManifestService manifest;
  @protected
  final SelectionBloc selectionBloc;

  Map<int, CollectibleData>? _collectiblesData;
  Map<int, DefinitionItemInfo>? _genericItems;
  Map<int, List<InventoryItemInfo>>? _inventoryItems;

  List<int>? get parentNodeHashes;

  Map<String, DestinyCharacterInfo>? _characters;

  @protected
  Map<int, DestinyPresentationNodeDefinition?> nodeDefinitions = {};

  DestinyPresentationNodeDefinition? get rootNode;
  List<DestinyPresentationNodeDefinition>? get tabNodes;

  Map<int, PresentationNodeProgressData?>? _presentationNodesCompletionData;
  List<DestinyPresentationNodeCollectibleChildEntry>? sortedCollectibles;

  CollectionsBloc(BuildContext this.context)
      : this.profileBloc = context.read<ProfileBloc>(),
        this.userSettings = context.read<UserSettingsBloc>(),
        this.manifest = context.read<ManifestService>(),
        this.selectionBloc = context.read<SelectionBloc>(),
        super() {
    init();
  }

  @protected
  init() {
    profileBloc.addListener(_update);
    _update();
    _loadDefinitions();
  }

  @override
  void dispose() {
    profileBloc.removeListener(_update);
    super.dispose();
  }

  void _loadDefinitions() async {
    await loadDefinitions();
    _update();
  }

  void _update() {
    update();
    updateCharacters();
    profileBloc.includeComponentsInNextRefresh(ProfileComponentGroups.collections);
    notifyListeners();
  }

  void update();

  void updateCharacters() {
    final characterEntries = profileBloc.characters?.map((e) => MapEntry(e.characterId ?? "", e));
    _characters = characterEntries != null ? Map.fromEntries(characterEntries) : null;
  }

  @protected
  Future<void> loadDefinitions();

  @protected
  Future<void> loadNodeDefinitions(Iterable<int> presentationNodeHash) async {
    final nodeDefs = await manifest.getDefinitions<DestinyPresentationNodeDefinition>(presentationNodeHash);
    nodeDefinitions.addAll(nodeDefs);
    for (final nodeDef in nodeDefs.values) {
      await _prepareChildCollectibles(nodeDef.children?.collectibles);
    }
  }

  Future<void> _prepareChildCollectibles(List<DestinyPresentationNodeCollectibleChildEntry>? collectibles) async {
    final collectibleHashes = collectibles?.map((e) => e.collectibleHash).whereType<int>() ?? <int>[];
    final collectibleDefinitions = await manifest.getDefinitions<DestinyCollectibleDefinition>(collectibleHashes);
    final itemHashes = collectibleDefinitions.values.map((c) => c.itemHash);
    final itemDefinitions = await manifest.getDefinitions<DestinyInventoryItemDefinition>(itemHashes);
    final genericItems = _genericItems ?? Map<int, DefinitionItemInfo>();
    final inventoryItems = _inventoryItems ?? Map<int, List<InventoryItemInfo>>();
    for (final h in collectibleHashes) {
      final itemHash = collectibleDefinitions[h]?.itemHash;
      final def = itemDefinitions[itemHash];
      if (def == null) continue;
      final item = DefinitionItemInfo.fromDefinition(def);
      genericItems[h] = item;
      inventoryItems[h] = profileBloc.getItemsByHash(itemHash);
    }
    _genericItems = genericItems;
    _inventoryItems = inventoryItems;

    if (collectibles == null) return;
    final items = itemDefinitions.values.whereType<DestinyInventoryItemDefinition>().toList();
    Set<DestinyItemType?> itemTypes = items.map((e) => e.itemType).toSet();
    if (itemTypes.length != 1) return;
    if (items[0].itemSubType == DestinyItemSubType.Ornament ||
        itemTypes.first == DestinyItemType.Weapon && items[0].inventory?.tierType == TierType.Exotic) {
      sortedCollectibles = collectibles.reversed.toList();
    } else if (itemTypes.first == DestinyItemType.Weapon ||
        itemTypes.first == DestinyItemType.Emblem ||
        items[0].itemSubType == DestinyItemSubType.Shader) {
      _bucketSortCollectibles(collectibles, collectibleDefinitions, itemDefinitions,
          (DestinyInventoryItemDefinition item) => -(item.inventory?.tierType?.value ?? 0));
    } else if (itemTypes.first == DestinyItemType.Armor && items[0].inventory?.tierType == TierType.Exotic) {
      _bucketSortCollectibles(collectibles, collectibleDefinitions, itemDefinitions,
          (DestinyInventoryItemDefinition item) => item.itemSubType?.value ?? 0);
    }
  }

  // Sort collectibles by putting them into buckets based on their tier, type, subType, etc.
  // and then combine the buckets back into a list
  void _bucketSortCollectibles(
      List<DestinyPresentationNodeCollectibleChildEntry> collectibles,
      Map<int, DestinyCollectibleDefinition> collectibleDefinitions,
      Map<int, DestinyInventoryItemDefinition> itemDefinitions,
      Function getKey) {
    Map<int, List<DestinyPresentationNodeCollectibleChildEntry>> buckets = {};
    List<DestinyPresentationNodeCollectibleChildEntry> leftovers = [];
    for (final collectible in collectibles.reversed) {
      final collectibleDef = collectibleDefinitions[collectible.collectibleHash];
      if (collectibleDef == null) {
        leftovers.add(collectible);
        continue;
      }
      final item = itemDefinitions[collectibleDef.itemHash];
      if (item == null) {
        leftovers.add(collectible);
        continue;
      }
      final key = getKey(item);
      if (buckets.containsKey(key))
        buckets[key]?.add(collectible);
      else
        buckets[key] = [collectible];
    }
    final keys = buckets.keys.toList()..sort();
    sortedCollectibles =
        <DestinyPresentationNodeCollectibleChildEntry>[for (final key in keys) ...buckets[key] ?? []] + leftovers;
  }

  @protected
  Future<void> updatePresentationNodeChildren(Iterable<int?> presentationNodeHashes) async {
    final nodeDefs = await manifest.getDefinitions<DestinyPresentationNodeDefinition>(presentationNodeHashes);
    final nodeChildHashes = nodeDefs.values.map((e) {
      final nodeHash = e.hash;
      final childHashes = e.children?.presentationNodes?.map((e) => e.presentationNodeHash) ?? <int?>[];
      return [nodeHash, ...childHashes];
    }).fold<List<int?>>([], (previousValue, element) => previousValue + element).whereType<int>();

    final completionData = _presentationNodesCompletionData ??= {};
    completionData
        .addEntries(nodeChildHashes.map((e) => MapEntry(e, getPresentationNodeCompletionData(profileBloc, e))));

    final collectibleChildHashes = nodeDefs.values.map((e) {
      final childHashes = e.children?.collectibles?.map((e) => e.collectibleHash) ?? <int?>[];
      return childHashes.toList();
    }).fold<List<int?>>([], (previousValue, element) => previousValue + element).whereType<int>();
    final collectibleData = _collectiblesData ??= {};
    collectibleData.addEntries(collectibleChildHashes.map((e) => MapEntry(e, getCollectibleData(profileBloc, e))));
  }

  PresentationNodeProgressData? getProgress(int? presentationNodeHash) =>
      _presentationNodesCompletionData?[presentationNodeHash];

  Map<String, DestinyCharacterInfo>? get characters => _characters;

  void openPresentationNode(int? presentationNodeHash, {List<int>? parentHashes});

  bool isUnlocked(int? hash) {
    if (hash == null) return false;
    final data = _collectiblesData?[hash];
    if (data == null) return true;
    final values = [data.profile, ...data.characters.values].whereType<DestinyCollectibleComponent>();
    if (values.isEmpty) return true;
    return values.any((element) => !(element.state?.contains(DestinyCollectibleState.NotAcquired) ?? false));
  }

  DefinitionItemInfo? getGenericItem(int? hash) => _genericItems?[hash];
  List<InventoryItemInfo>? getInventoryItems(int? hash) => _inventoryItems?[hash];

  void onCollectibleTap(DestinyItemInfo item) {
    final hash = item.itemHash;

    if (hash == null) return;

    if (selectionBloc.hasSelection || userSettings.tapToSelect) {
      final items = profileBloc.getItemsByHash(hash);
      if (items.isEmpty) return;
      final areAllSelected = items.every((element) => selectionBloc.isItemSelected(element));
      if (areAllSelected) {
        selectionBloc.unselectItems(items);
      } else {
        selectionBloc.selectItems(items);
      }
      return;
    }

    Navigator.of(context).push(DefinitionItemDetailsPageRoute(hash));
  }

  void onCollectibleHold(DestinyItemInfo item) {
    final hash = item.itemHash;
    if (hash == null) return;

    if (userSettings.tapToSelect) {
      Navigator.of(context).push(DefinitionItemDetailsPageRoute(hash));
      return;
    }

    final items = profileBloc.getItemsByHash(hash);
    if (items.isEmpty) return;

    final allSelected = items.every((element) => selectionBloc.isItemSelected(element));
    if (allSelected) {
      selectionBloc.unselectItems(items);
    } else {
      selectionBloc.selectItems(items);
    }
  }
}
