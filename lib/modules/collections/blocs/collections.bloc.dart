import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/core/blocs/profile/profile_component_groups.dart';
import 'package:little_light/core/blocs/selection/selection.bloc.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/models/item_info/definition_item_info.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';
import 'package:little_light/modules/collections/pages/subcategory/collections_subcategory.page_route.dart';
import 'package:little_light/modules/item_details/pages/definition_item_details/definition_item_details.page_route.dart';
import 'package:little_light/services/analytics/analytics.consumer.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/shared/utils/helpers/presentation_node_helpers.dart';
import 'package:provider/provider.dart';

abstract class CollectionsBloc extends ChangeNotifier {
  final BuildContext context;
  final ProfileBloc _profileBloc;
  final UserSettingsBloc _userSettings;
  final ManifestService _manifest;
  final SelectionBloc _selectionBloc;
  final int categoryPresentationNodeHash;

  Map<int, CollectibleData>? _collectiblesData;
  Map<int, DefinitionItemInfo>? _genericItems;
  Map<int, List<InventoryItemInfo>>? _inventoryItems;

  List<int>? _parentNodeHashes;
  List<int>? get parentNodeHashes => _parentNodeHashes;

  DestinyPresentationNodeDefinition? _rootNodeDefinition;
  DestinyPresentationNodeDefinition? get rootNode => _rootNodeDefinition;

  Map<String, DestinyCharacterInfo>? _characters;

  List<DestinyPresentationNodeDefinition>? get tabNodes {
    final node = rootNode;
    if (node != null) return [node];
    return null;
  }

  Map<int, PresentationNodeProgressData?>? _presentationNodesCompletionData;

  CollectionsBloc(BuildContext this.context, this.categoryPresentationNodeHash)
      : this._profileBloc = context.read<ProfileBloc>(),
        this._userSettings = context.read<UserSettingsBloc>(),
        this._manifest = context.read<ManifestService>(),
        this._selectionBloc = context.read<SelectionBloc>(),
        super() {
    _init();
  }

  @protected
  _init() {
    _profileBloc.includeComponentsInNextRefresh(ProfileComponentGroups.collections);
    _profileBloc.addListener(_update);
    _update();
    loadDefinitions();
  }

  @protected
  void loadNodeDefinitions(int presentationNodeHash) async {
    final nodeDef = await _manifest.getDefinition<DestinyPresentationNodeDefinition>(categoryPresentationNodeHash);
    await _prepareChildCollectibles(nodeDef?.children?.collectibles);
  }

  Future<void> _prepareChildCollectibles(List<DestinyPresentationNodeCollectibleChildEntry>? collectibles) async {
    final collectibleHashes = collectibles?.map((e) => e.collectibleHash).whereType<int>() ?? <int>[];
    final collectibleDefinitions = await _manifest.getDefinitions<DestinyCollectibleDefinition>(collectibleHashes);
    final itemHashes = collectibleDefinitions.values.map((c) => c.itemHash);
    final itemDefinitions = await _manifest.getDefinitions<DestinyInventoryItemDefinition>(itemHashes);
    final genericItems = _genericItems ?? Map<int, DefinitionItemInfo>();
    for (final h in collectibleHashes) {
      final itemHash = collectibleDefinitions[h]?.itemHash;
      final def = itemDefinitions[itemHash];
      if (def == null) continue;
      final item = DefinitionItemInfo.fromDefinition(def);
      genericItems[h] = item;
    }
    _genericItems = genericItems;
  }

  @protected
  void loadDefinitions();

  @override
  void dispose() {
    _profileBloc.removeListener(_update);
    super.dispose();
  }

  void _update() {
    final presentationNodeHash = _rootNodeDefinition?.hash;
    final presentationNodeChildHashes =
        _rootNodeDefinition?.children?.presentationNodes?.map((e) => e.presentationNodeHash) ?? <int?>[];
    final presentationNodeHashes = [presentationNodeHash, ...presentationNodeChildHashes].whereType<int>();

    final collectibleHashes =
        _rootNodeDefinition?.children?.collectibles?.map((e) => e.collectibleHash).whereType<int>() ?? <int>[];

    _presentationNodesCompletionData = {
      for (final h in presentationNodeHashes) h: getPresentationNodeCompletionData(_profileBloc, h)
    };

    _collectiblesData = {
      for (final h in collectibleHashes) h: getCollectibleData(_profileBloc, h),
    };

    _inventoryItems = {
      for (final h in collectibleHashes) h: _profileBloc.getItemsByHash(_genericItems?[h]?.itemHash),
    };

    final characterEntries = _profileBloc.characters?.map((e) => MapEntry(e.characterId ?? "", e));
    _characters = characterEntries != null ? Map.fromEntries(characterEntries) : null;

    _profileBloc.includeComponentsInNextRefresh(ProfileComponentGroups.collections);
    notifyListeners();
  }

  PresentationNodeProgressData? getProgress(int presentationNodeHash) =>
      _presentationNodesCompletionData?[presentationNodeHash];

  Map<String, DestinyCharacterInfo>? get characters => _characters;

  void openPresentationNode(int presentationNodeHash) {
    Navigator.of(context).push(CollectionsSubcategoryPageRoute(presentationNodeHash));
  }

  bool isUnlocked(int hash) {
    final data = _collectiblesData?[hash];
    if (data == null) return true;
    final values = [data.profile, ...data.characters.values].whereType<DestinyCollectibleComponent>();
    if (values.isEmpty) return true;
    return values.any((element) => !(element.state?.contains(DestinyCollectibleState.NotAcquired) ?? false));
  }

  DefinitionItemInfo? getGenericItem(int hash) => _genericItems?[hash];
  List<InventoryItemInfo>? getInventoryItems(int hash) => _inventoryItems?[hash];

  void onItemTap(DestinyItemInfo item) {
    final hash = item.itemHash;

    if (hash == null) return;

    if (_selectionBloc.hasSelection || _userSettings.tapToSelect) {
      final items = _profileBloc.getItemsByHash(hash);
      if (items.isEmpty) return;
      final areAllSelected = items.every((element) => _selectionBloc.isItemSelected(element));
      if (areAllSelected) {
        _selectionBloc.unselectItems(items);
      } else {
        _selectionBloc.selectItems(items);
      }
      return;
    }

    Navigator.of(context).push(DefinitionItemDetailsPageRoute(hash));
  }

  void onItemHold(DestinyItemInfo item) {
    final hash = item.itemHash;
    if (hash == null) return;

    if (_userSettings.tapToSelect) {
      Navigator.of(context).push(DefinitionItemDetailsPageRoute(hash));
      return;
    }

    final items = _profileBloc.getItemsByHash(hash);
    if (items.isEmpty) return;

    final allSelected = items.every((element) => _selectionBloc.isItemSelected(element));
    if (allSelected) {
      _selectionBloc.unselectItems(items);
    } else {
      _selectionBloc.selectItems(items);
    }
  }
}
