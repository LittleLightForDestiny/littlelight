import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/core/blocs/profile/profile_component_groups.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/modules/collections/pages/category/collections_category.page_route.dart';
import 'package:little_light/modules/collections/pages/subcategory/collections_subcategory.page_route.dart';
import 'package:little_light/services/analytics/analytics.consumer.dart';
import 'package:little_light/services/analytics/analytics.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/destiny_settings.consumer.dart';
import 'package:little_light/services/profile/destiny_settings.service.dart';
import 'package:little_light/services/user_settings/little_light_persistent_page.dart';
import 'package:little_light/shared/utils/helpers/presentation_node_helpers.dart';
import 'package:provider/provider.dart';

const _page = LittleLightPersistentPage.Collections;

class CollectionsHomeBloc extends ChangeNotifier {
  final BuildContext context;
  final ProfileBloc _profileBloc;
  final UserSettingsBloc _userSettings;
  final AnalyticsService _analytics;
  final DestinySettingsService _destinySettings;
  final ManifestService _manifest;

  List<DestinyPresentationNodeDefinition>? _rootNodesDefinitions;

  Map<String, DestinyCharacterInfo>? _characters;

  List<DestinyPresentationNodeDefinition>? get tabNodes => _rootNodesDefinitions;
  Map<int, PresentationNodeProgressData?>? _presentationNodesCompletionData;

  CollectionsHomeBloc(BuildContext this.context)
      : this._profileBloc = context.read<ProfileBloc>(),
        this._userSettings = context.read<UserSettingsBloc>(),
        this._analytics = getInjectedAnalyticsService(),
        this._destinySettings = getInjectedDestinySettingsService(),
        this._manifest = context.read<ManifestService>(),
        super() {
    _init();
  }

  _init() {
    _profileBloc.includeComponentsInNextRefresh(ProfileComponentGroups.collections);
    _profileBloc.refresh();
    _userSettings.startingPage = _page;
    _analytics.registerPageOpen(_page);
    _profileBloc.addListener(_update);
    _update();
    loadRootNodes();
  }

  void loadRootNodes() async {
    final rootNodes = [
      _destinySettings.collectionsRootNode,
      _destinySettings.badgesRootNode,
    ];
    final definitions = await _manifest.getDefinitions<DestinyPresentationNodeDefinition>(rootNodes);
    this._rootNodesDefinitions = rootNodes
        .map((h) => definitions[h]) //
        .whereType<DestinyPresentationNodeDefinition>()
        .toList();
    _update();
  }

  @override
  void dispose() {
    _profileBloc.removeListener(_update);
    super.dispose();
  }

  void _update() {
    final hashes = _rootNodesDefinitions?.map((e) {
          final nodeHash = e.hash;
          final childHashes = e.children?.presentationNodes?.map((e) => e.presentationNodeHash) ?? <int?>[];
          return [nodeHash, ...childHashes];
        }).fold<List<int?>>([], (previousValue, element) => previousValue + element).whereType<int>() ??
        [];

    _presentationNodesCompletionData = {for (final h in hashes) h: getPresentationNodeCompletionData(_profileBloc, h)};

    final characterEntries = _profileBloc.characters?.map((e) => MapEntry(e.characterId ?? "", e));
    _characters = characterEntries != null ? Map.fromEntries(characterEntries) : null;

    _profileBloc.includeComponentsInNextRefresh(ProfileComponentGroups.collections);
    notifyListeners();
  }

  PresentationNodeProgressData? getProgress(int presentationNodeHash) =>
      _presentationNodesCompletionData?[presentationNodeHash];

  Map<String, DestinyCharacterInfo>? get characters => _characters;

  void openPresentationNode(int presentationNodeHash) async {
    Navigator.of(context).push(CollectionsCategoryPageRoute(presentationNodeHash));
  }
}
