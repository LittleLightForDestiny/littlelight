import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/item_notes/item_notes.bloc.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/core/blocs/profile/sorters.dart';
import 'package:little_light/core/blocs/selection/selection.bloc.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/models/game_data.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';
import 'package:little_light/shared/modals/context_menu_overlay/character_context_menu.route.dart';
import 'package:little_light/modules/item_details/pages/inventory_item_details/inventory_item_details.page_route.dart';
import 'package:little_light/modules/search/pages/pursuit_search/pursuit_search.page_route.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/littlelight/littlelight_data.consumer.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/user_settings/little_light_persistent_page.dart';
import 'package:little_light/shared/utils/sorters/items/export.dart';
import 'package:little_light/shared/widgets/tabs/custom_tab/custom_tab.dart';
import 'package:provider/provider.dart';

typedef CharactersQuests = Map<String, Map<int?, List<DestinyItemInfo>>>;
typedef CharactersBounties = Map<String, List<DestinyItemInfo>>;

class CharacterPursuits {
  Map<int?, List<DestinyItemInfo>> quests = {};
  List<DestinyItemInfo> bounties = [];
  List<int?>? questCategories;

  Future<void> sortQuestCategories(ManifestService manifest) async {
    final defs = await manifest.getDefinitions<DestinyTraitDefinition>(quests.keys);
    final sorted = quests.keys.sortedBy((element) => defs[element]?.index ?? double.maxFinite);
    questCategories = sorted.toList();
  }
}

class _ProgressState {
  Map<String, CharacterPursuits> pursuits = {};

  void addPursuit(DestinyItemInfo item, DestinyInventoryItemDefinition? def) {
    final isBounty = def?.itemType == DestinyItemType.Bounty;
    if (isBounty) {
      return addBounty(item);
    }
    return addQuest(item, def);
  }

  void addBounty(DestinyItemInfo item) {
    final characterId = item.characterId;
    if (characterId == null) return;
    final characterPursuits = pursuits[characterId] ??= CharacterPursuits();
    characterPursuits.bounties.add(item);
  }

  void addQuest(DestinyItemInfo item, DestinyInventoryItemDefinition? def) {
    final characterId = item.characterId;
    if (characterId == null) return;
    final characterPursuits = pursuits[characterId] ??= CharacterPursuits();
    final traitIndex = def?.traitIds?.indexWhere((element) => element.contains('quest.')) ?? -1;
    final traitHash = traitIndex >= 0 ? def?.traitHashes?.elementAtOrNull(traitIndex) : null;
    final categoryQuests = characterPursuits.quests[traitHash] ??= [];
    categoryQuests.add(item);
  }

  Future<void> sortCategories(ManifestService manifest) async {
    await Future.wait(pursuits.values.map((e) => e.sortQuestCategories(manifest)));
  }
}

class ProgressBloc extends ChangeNotifier with ManifestConsumer, LittleLightDataConsumer {
  final BuildContext _context;
  final ProfileBloc _profileBloc;
  final SelectionBloc _selectionBloc;
  final UserSettingsBloc _userSettingsBloc;
  final ItemNotesBloc _itemNotesBloc;
  final PageStorageBucket _pageStorageBucket = PageStorageBucket();
  PageStorageBucket get pageStorageBucket => _pageStorageBucket;
  GameData? _gameData;

  _ProgressState _equipmentState = _ProgressState();

  ProgressBloc(this._context)
      : _profileBloc = _context.read<ProfileBloc>(),
        _selectionBloc = _context.read<SelectionBloc>(),
        _userSettingsBloc = _context.read<UserSettingsBloc>(),
        _itemNotesBloc = _context.read<ItemNotesBloc>() {
    _init();
  }
  _init() {
    _userSettingsBloc.startingPage = LittleLightPersistentPage.Progress;
    _profileBloc.addListener(_update);
    _userSettingsBloc.addListener(_update);
    _itemNotesBloc.addListener(_update);
    _update();
    _loadGameData();
  }

  void _loadGameData() async {
    _gameData = await littleLightData.getGameData();
    notifyListeners();
  }

  @override
  void dispose() {
    _profileBloc.removeListener(_update);
    _userSettingsBloc.removeListener(_update);
    _itemNotesBloc.removeListener(_update);
    super.dispose();
  }

  void _update() async {
    final equipmentState = _ProgressState();
    final priorityTags = _userSettingsBloc.priorityTags ?? <String>[];
    final parameters = _userSettingsBloc.pursuitOrdering;
    List<DestinyItemInfo> items = _profileBloc.allItems;
    final characters = _profileBloc.characters;

    if (parameters != null && characters != null) {
      final hashes = items.map((e) => e.itemHash).whereType<int>();
      final definitions = await manifest.getDefinitions<DestinyInventoryItemDefinition>(hashes);
      final sorters = getSortersFromStorage(parameters, _context, definitions, characters);
      items = await MultiSorter([
        if (priorityTags.isNotEmpty) PriorityTagsSorter(_context, priorityTags),
        ...sorters,
      ]).sort(_profileBloc.allItems);
    }
    final pursuits = items.where((i) => i.bucketHash == InventoryBucket.pursuits);

    for (final item in pursuits) {
      final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(item.itemHash);
      equipmentState.addPursuit(item, def);
    }

    equipmentState.sortCategories(manifest);

    _equipmentState = equipmentState;
    notifyListeners();
  }

  List<DestinyCharacterInfo>? get characters => _profileBloc.characters;

  List<DestinyItemInfo>? getQuestsForCategory(DestinyCharacterInfo character, int? categoryId) {
    final characterId = character.characterId;
    if (characterId == null) return null;
    return _equipmentState.pursuits[characterId]?.quests[categoryId];
  }

  List<DestinyItemComponent>? get relevantCurrencies {
    final allCurrencies = _profileBloc.currencies;
    if (allCurrencies == null) return null;
    final relevant = _gameData?.relevantCurrencies;
    if (relevant == null) return null;
    return relevant
        .map((r) => allCurrencies.firstWhereOrNull((c) => c.itemHash == r))
        .whereType<DestinyItemComponent>()
        .toList();
  }

  void onItemTap(InventoryItemInfo item) {
    final hash = item.itemHash;
    final instanceId = item.instanceId;
    final stackIndex = item.stackIndex;

    if (hash == null) return;

    if (_selectionBloc.hasSelection || _userSettingsBloc.tapToSelect) {
      return _selectionBloc.toggleSelected(
        hash,
        instanceId: instanceId,
        stackIndex: stackIndex,
      );
    }

    Navigator.of(_context).push(InventoryItemDetailsPageRoute(item));
  }

  void onItemHold(InventoryItemInfo item) {
    final hash = item.itemHash;
    final instanceId = item.instanceId;
    final stackIndex = item.stackIndex;
    if (hash == null) return;
    if (_userSettingsBloc.tapToSelect) {
      Navigator.of(_context).push(InventoryItemDetailsPageRoute(item));
      return;
    }
    return _selectionBloc.toggleSelected(
      hash,
      instanceId: instanceId,
      stackIndex: stackIndex,
    );
  }

  void openSearch() {
    Navigator.of(_context).push(PursuitSearchPageRoute());
  }

  List<int?>? pursuitCategoriesFor(DestinyCharacterInfo character) {
    return _equipmentState.pursuits[character.characterId]?.questCategories;
  }

  List<DestinyItemInfo>? bountiesFor(DestinyCharacterInfo character) {
    return _equipmentState.pursuits[character.characterId]?.bounties;
  }

  void openContextMenu(CustomTabController characterTabController) {
    final characters = this.characters;
    if (characters == null) return;
    Navigator.of(_context)
        .push(CharacterContextMenuModalRoute(characterTabController, characters: characters, onSearchTap: openSearch));
  }
}
