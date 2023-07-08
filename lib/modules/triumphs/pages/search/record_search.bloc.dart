import 'dart:async';

import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/modules/triumphs/pages/record_details/record_details.page_route.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/shared/utils/extensions/string/remove_diacritics.dart';
import 'package:little_light/shared/utils/helpers/presentation_node_helpers.dart';
import 'package:provider/provider.dart';

class RecordsSearchBloc extends ChangeNotifier {
  final int rootNodeHash;

  @protected
  final BuildContext context;

  @protected
  final ManifestService manifest;

  @protected
  final ProfileBloc profile;

  Map<int, DestinyRecordDefinition>? _recordDefs;

  Map<int, RecordProgressData>? _recordData;

  List<int>? _filteredItems;
  List<int>? get filteredItems => _filteredItems;

  Timer? _searchTimer;
  String _textSearch = "";
  set textSearch(String value) {
    _textSearch = value;
    final isTimerActive = _searchTimer?.isActive ?? false;
    if (isTimerActive) {
      return;
    }
    _searchTimer = Timer(Duration(milliseconds: 300), () {
      _updateFiltered();
    });
  }

  RecordsSearchBloc(this.context, int this.rootNodeHash)
      : manifest = context.read<ManifestService>(),
        profile = context.read<ProfileBloc>(),
        super() {
    _init();
  }

  void _init() {
    profile.addListener(_updateFromProfile);
    loadDefinitions();
  }

  @override
  void dispose() {
    super.dispose();
    profile.removeListener(_updateFromProfile);
  }

  Future<void> loadDefinitions() async {
    final recordHashes = await loadChildrenRecordHashes(rootNodeHash);
    final recordDefs = await manifest.getDefinitions<DestinyRecordDefinition>(recordHashes);
    this._recordDefs = recordDefs;
    _updateFromProfile();
  }

  void _updateFromProfile() {
    _updateFiltered();
  }

  Future<void> _updateFiltered() async {
    final filteredItems = <int>[];
    final records = _recordDefs;
    if (records == null) return;
    final search = removeDiacritics(_textSearch.toLowerCase().trim());
    for (final record in records.values) {
      final recordHash = record.hash;
      if (recordHash == null) continue;
      final name = removeDiacritics(record.displayProperties?.name?.toLowerCase().trim() ?? "");
      if (search.isEmpty) {
        filteredItems.add(recordHash);
        continue;
      }
      if (name.startsWith(search)) {
        filteredItems.add(recordHash);
        continue;
      }
      if (search.length > 3 && name.contains(search)) {
        filteredItems.add(recordHash);
        continue;
      }
    }
    _filteredItems = filteredItems;
    notifyListeners();
  }

  Future<Set<int>> loadChildrenRecordHashes(int nodeHash) async {
    final definition = await manifest.getDefinition<DestinyPresentationNodeDefinition>(nodeHash);
    final recordHashes = definition?.children?.records //
            ?.map((e) => e.recordHash)
            .whereType<int>()
            .toSet() ??
        <int>{};
    final presentationNodeHashes = definition?.children?.presentationNodes //
            ?.map((e) => e.presentationNodeHash)
            .whereType<int>()
            .toSet() ??
        <int>{};
    if (presentationNodeHashes.isNotEmpty) {
      await manifest.getDefinitions<DestinyPresentationNodeDefinition>(presentationNodeHashes);
      for (final presentationNodeHash in presentationNodeHashes) {
        recordHashes.addAll(await loadChildrenRecordHashes(presentationNodeHash));
      }
    }
    return recordHashes;
  }

  RecordProgressData? getProgressData(int? recordHash) {
    if (recordHash == null) return null;
    final recordData = _recordData ??= {};
    final generic = recordData[recordHash] ??= getRecordData(profile, recordHash);
    return generic;
  }

  void onRecordTap(DestinyItemInfo item) {
    final hash = item.itemHash;
    if (hash == null) return;
    Navigator.of(context).push(RecordDetailsPageRoute(hash));
  }
}
