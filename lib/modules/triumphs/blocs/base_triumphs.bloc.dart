import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/objective_tracking/objective_tracking.bloc.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/core/blocs/profile/profile_component_groups.dart';
import 'package:little_light/core/blocs/selection/selection.bloc.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/modules/triumphs/pages/record_details/record_details.page_route.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/shared/utils/helpers/presentation_node_helpers.dart';
import 'package:provider/provider.dart';

abstract class TriumphsBloc extends ChangeNotifier {
  final BuildContext context;
  @protected
  final ProfileBloc profileBloc;
  @protected
  final UserSettingsBloc userSettings;
  @protected
  final ManifestService manifest;
  @protected
  final SelectionBloc selectionBloc;
  @protected
  final ObjectiveTrackingBloc trackingBloc;

  Map<int, RecordProgressData>? _recordsData;

  List<int>? get parentNodeHashes;

  Map<String, DestinyCharacterInfo>? _characters;

  @protected
  Map<int, DestinyPresentationNodeDefinition?> nodeDefinitions = {};

  DestinyPresentationNodeDefinition? get rootNode;
  List<DestinyPresentationNodeDefinition>? get tabNodes;

  Map<int, PresentationNodeProgressData?>? _presentationNodesCompletionData;

  TriumphsBloc(BuildContext this.context)
      : this.profileBloc = context.read<ProfileBloc>(),
        this.userSettings = context.read<UserSettingsBloc>(),
        this.manifest = context.read<ManifestService>(),
        this.selectionBloc = context.read<SelectionBloc>(),
        this.trackingBloc = context.read<ObjectiveTrackingBloc>(),
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
    profileBloc.includeComponentsInNextRefresh(ProfileComponentGroups.triumphs);
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
  }

  @protected
  Future<void> updatePresentationNodeChildren(Iterable<int?> presentationNodeHashes) async {
    final nodeDefs = await manifest.getDefinitions<DestinyPresentationNodeDefinition>(presentationNodeHashes);
    final childHashes = nodeDefs.values.map((e) {
      final nodeHash = e.hash;
      final childHashes = e.children?.presentationNodes?.map((e) => e.presentationNodeHash) ?? <int?>[];
      return [nodeHash, ...childHashes];
    }).fold<List<int?>>([], (previousValue, element) => previousValue + element).whereType<int>();

    final completionData = _presentationNodesCompletionData ??= {};
    completionData.addEntries(childHashes.map((e) => MapEntry(e, getPresentationNodeCompletionData(profileBloc, e))));

    final recordChildHashes = nodeDefs.values //
        .map((e) {
          final childHashes = e.children?.records?.map((e) => e.recordHash) ?? <int?>[];
          return childHashes.toList();
        })
        .fold<List<int?>>([], (previousValue, element) => previousValue + element)
        .whereType<int>()
        .toSet();

    final recordsData = _recordsData ??= <int, RecordProgressData>{};
    recordsData.addEntries(recordChildHashes.map((e) => MapEntry(e, getRecordData(profileBloc, e))));
  }

  PresentationNodeProgressData? getProgress(int? presentationNodeHash) =>
      _presentationNodesCompletionData?[presentationNodeHash];

  Map<String, DestinyCharacterInfo>? get characters => _characters;

  void openPresentationNode(int? presentationNodeHash, {List<int>? parentHashes});

  RecordProgressData? getRecordProgress(int? recordHash) => _recordsData?[recordHash];

  void onRecordTap(int? recordHash) {
    if (recordHash == null) return;
    Navigator.of(context).push(RecordDetailsPageRoute(recordHash));
  }
}
