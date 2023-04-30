import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/modules/triumphs/blocs/base_triumphs.bloc.dart';
import 'package:little_light/modules/triumphs/pages/category/triumphs_category.page_route.dart';
import 'package:little_light/services/analytics/analytics.consumer.dart';
import 'package:little_light/services/analytics/analytics.service.dart';
import 'package:little_light/services/profile/destiny_settings.consumer.dart';
import 'package:little_light/services/profile/destiny_settings.service.dart';
import 'package:little_light/services/user_settings/little_light_persistent_page.dart';
import 'package:provider/provider.dart';

const _page = LittleLightPersistentPage.Triumphs;

class TriumphsHomeBloc extends TriumphsBloc {
  @override
  DestinyPresentationNodeDefinition? get rootNode => null;

  @override
  List<DestinyPresentationNodeDefinition>? get tabNodes => _tabNodeDefinitions;
  List<DestinyPresentationNodeDefinition>? _tabNodeDefinitions;

  @protected
  final DestinySettingsService destinySettings;

  @protected
  final AnalyticsService analytics;

  @protected
  final UserSettingsBloc userSettings;

  TriumphsHomeBloc(BuildContext context)
      : this.destinySettings = getInjectedDestinySettingsService(),
        this.analytics = getInjectedAnalyticsService(),
        this.userSettings = context.read<UserSettingsBloc>(),
        super(context);

  @override
  init() {
    super.init();
    analytics.registerPageOpen(_page);
    userSettings.startingPage = _page;
    profileBloc.refresh();
  }

  @override
  Future<void> loadDefinitions() async {
    final nodeHashes = [
      destinySettings.triumphsRootNode,
      destinySettings.loreRootNode,
      destinySettings.catalystsRootNode,
      destinySettings.sealsRootNode,
      destinySettings.legacyTriumphsRootNode,
      destinySettings.legacySealsRootNode,
    ].whereType<int>();
    await loadNodeDefinitions(nodeHashes);
    _tabNodeDefinitions = nodeHashes //
        .map((e) => nodeDefinitions[e])
        .whereType<DestinyPresentationNodeDefinition>()
        .toList();
  }

  @override
  void openPresentationNode(int? presentationNodeHash, {List<int>? parentHashes}) {
    if (presentationNodeHash == null) return;
    Navigator.of(context).push(
      TriumphsCategoryPageRoute(presentationNodeHash, parentNodeHashes: [
        if (parentHashes != null) ...parentHashes,
        presentationNodeHash,
      ]),
    );
  }

  @override
  List<int>? get parentNodeHashes => null;

  @override
  void update() {
    final hashes = _tabNodeDefinitions?.map((e) => e.hash);
    if (hashes == null) return;
    updatePresentationNodeChildren(hashes);
  }
}
